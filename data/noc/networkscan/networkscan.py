# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------
# Pretty command ver.6
# ----------------------------------------------------------------------
# Copyright (C) 2007-2019 The NOC Project
# See LICENSE for details
# ----------------------------------------------------------------------

# Python modules
import argparse
import datetime
import StringIO
import base64
import time

# Third-party modules
from tornado.ioloop import IOLoop
import tornado.gen
import tornado.queues
import xlsxwriter
import logging

# NOC modules
from noc.core.management.base import BaseCommand
from noc.core.validators import is_ipv4
from noc.core.ioloop.ping import Ping

# from noc.config import config
from noc.core.ip import IP, IPv4
from noc.core.ioloop.snmp import snmp_get, SNMPError

# from noc.core.bkport.time import perf_counter
from noc.core.mib import mib
from noc.core.snmp.version import SNMP_v1, SNMP_v2c
from noc.sa.models.managedobject import ManagedObject
from noc.sa.models.authprofile import AuthProfile
from noc.main.models.pool import Pool

# from noc.main.models.notificationgroup import NotificationGroup
# from noc.core.profile.checker import ProfileChecker
from noc.inv.models.platform import Platform
from noc.services.mailsender.service import MailSenderService
from noc.core.mongo.connection import connect


class Command(BaseCommand):
    DEFAULT_OID = "1.3.6.1.2.1.1.2.0"
    DEFAULT_COMMUNITY = "public"
    CHECK_OIDS = [mib["SNMPv2-MIB::sysObjectID.0"], mib["SNMPv2-MIB::sysName.0"]]
    CHECK_VERSION = {SNMP_v1: "snmp_v2c_get", SNMP_v2c: "snmp_v1_get"}
    SNMP_VERSION = {0: "SNMP_v1", 1: "SNMP_v2c"}

    def add_arguments(self, parser):
        parser.add_argument("--in", action="append", dest="input", help="File with addresses")
        parser.add_argument(
            "--exclude", action="append", dest="exclude", help="File with addresses for exclusion"
        )
        parser.add_argument(
            "--jobs", action="store", type=int, default=100, dest="jobs", help="Concurrent jobs"
        )
        parser.add_argument("addresses", nargs=argparse.REMAINDER, help="Object name")
        parser.add_argument("--community", action="append", help="SNMP community")
        parser.add_argument("--oid", default=self.CHECK_OIDS, action="append", help="SNMP GET OIDs")
        parser.add_argument("--timeout", type=int, default=5, help="SNMP GET timeout")
        parser.add_argument("--convert", type=bool, default=False, help="convert mac address")
        parser.add_argument("--version", type=int, help="version snmp check")
        parser.add_argument("--auth", help="auth profile")
        parser.add_argument("--pool", help="name pool", default="default")
        parser.add_argument("--mail", help="mail notification_group name")
        parser.add_argument("--email", action="append", help="mailbox list")
        parser.add_argument("--format", default="csv", help="Format file (csv or xlsx)")

    def handle(
        self,
        input,
        exclude,
        addresses,
        jobs,
        community,
        oid,
        timeout,
        convert,
        version,
        auth,
        pool,
        mail,
        email,
        format,
        *args,
        **options
    ):
        connect()
        self.addresses = set()  # ip for ping
        self.enable_ping = set()  # ip отвечающие на ping
        self.not_ping = set()  # ip не отвечающие на ping
        self.enable_snmp = set()  # ip отвечающие на snmp
        self.hosts_enable = set()  # ip in noc
        self.hosts_exclude = set()  # ip exclude
        self.mo = {}
        self.time = {}  # время сканирования
        self.snmp = {}
        self.nets = []  # список сетей
        self.count_ping = 0
        self.count_not_ping = 0
        self.count_snmp = 0
        self.count_net = 0
        # Read addresses from files
        """
        file format example
        10.0.0.1
        10.1.1.0/24
        10.1.2.1
        """
        if exclude:
            for fn in exclude:
                try:
                    with open(fn) as f:
                        for line in f:
                            line = line.strip()
                            ip = line.split("/")
                            if is_ipv4(ip[0]):
                                if len(ip) == 2:
                                    ip = IP.prefix(line)
                                    first = ip.first
                                    last = ip.last
                                    for x in first.iter_address(until=last):
                                        ip2 = str(x).split("/")
                                        self.hosts_exclude.add(ip2[0])
                                else:
                                    self.hosts_exclude.add(line)
                except OSError as e:
                    self.die("Cannot read file %s: %s\n" % (fn, e))
        if version is None:
            self.version = [1, 0]
        else:
            self.version = [version]
        self.pool = Pool.objects.get(name=pool)
        data = "IP;Доступен по ICMP;IP есть в NOC;is_managed;SMNP sysname;SNMP sysObjectId;Vendor;Model;Имя в NOC;pool;tags\n"
        # столбцы x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12
        # создание списка наличия мо в noc
        moall = ManagedObject.objects.filter(is_managed=True)
        if pool:
            moall = moall.filter(pool=self.pool)
        for mm in moall:
            self.hosts_enable.add(mm.address)
            self.mo[mm.address] = {"name": mm.name, "tags": mm.tags, "is_managed": mm.is_managed}
        moall = ManagedObject.objects.filter(is_managed=False).exclude(
            tags__contains="remote:deleted"
        )
        if pool:
            moall = moall.filter(pool=self.pool)
        for mm in moall:
            if mm.address not in self.hosts_enable:
                self.hosts_enable.add(mm.address)
                self.mo[mm.address] = {
                    "name": mm.name,
                    "tags": mm.tags,
                    "is_managed": mm.is_managed,
                }
        #self.ff = "/tmp/ip%s.csv" % (input[0].replace("/", "-"))
        self.ff = "/tmp/ip.csv"
        # Direct addresses 10.0.0.1 or 10.0.0.0/24
        for a in addresses:
            self.addresses = set()
            self.nets.append(a)
            ip = a.split("/")
            file1 = open(self.ff, "w")
            if is_ipv4(ip[0]):
                if len(ip) == 2:
                    ip = IP.prefix(a)
                    first = ip.first
                    last = ip.last
                    for x in first.iter_address(until=last):
                        ip2 = str(x).split("/")
                        if ip2[0] not in self.hosts_exclude:
                            file1.write(ip2[0] + "\n")
                            # self.addresses.add(ip2[0])
                else:
                    if a not in self.hosts_exclude:
                        # self.addresses.add(a)
                        file1.write(a + "\n")
            file1.close()
        # Read addresses from files
        """
        file format example
        10.0.0.1
        10.1.1.0/24
        10.1.2.1
        """
        if input:
            for fn in input:
                try:
                    with open(fn) as f:
                        for line in f:
                            start = datetime.datetime.now()
                            file1 = open(self.ff, "w")
                            line = line.strip()
                            ip = line.split("/")
                            if is_ipv4(ip[0]):
                                self.nets.append(line)
                                if len(ip) == 2:
                                    ip = IP.prefix(line)
                                    first = ip.first
                                    last = ip.last
                                    for x in first.iter_address(until=last):
                                        ip2 = str(x).split("/")
                                        if ip2[0] not in self.hosts_exclude:
                                            file1.write(ip2[0] + "\n")
                                            # self.addresses.add(ip2[0])
                                else:
                                    if a not in self.hosts_exclude:
                                        # self.addresses.add(line)
                                        file1.write(line + "\n")
                                file1.close()

                                # Ping
                                # if config.features.use_uvlib:
                                #    from tornaduv import UVLoop
                                #    self.stderr.write("Using libuv\n")
                                #    tornado.ioloop.IOLoop.configure(UVLoop)
                                self.ioloop = IOLoop.current()
                                self.ping = Ping(io_loop=self.ioloop)
                                self.jobs = jobs
                                self.queue = tornado.queues.Queue(self.jobs)
                                for i in range(self.jobs):
                                    self.ioloop.spawn_callback(self.ping_worker)
                                self.ioloop.run_sync(self.ping_task)

                                # snmp
                                self.ioloop = IOLoop.current()
                                self.jobs = jobs
                                # self.convert = convert
                                self.queue = tornado.queues.Queue(self.jobs)

                                for i in range(self.jobs):
                                    self.ioloop.spawn_callback(
                                        self.poll_worker, community, oid, timeout, self.version
                                    )
                                self.ioloop.run_sync(self.poll_task)
                            file1.close()
                            stop = datetime.datetime.now()
                            delta = stop - start
                            self.time[line] = str(delta.seconds)

                except OSError as e:
                    self.die("Cannot read file %s: %s\n" % (fn, e))
        else:
            # Ping
            # if config.features.use_uvlib:
            #    from tornaduv import UVLoop
            #    self.stderr.write("Using libuv\n")
            #    tornado.ioloop.IOLoop.configure(UVLoop)
            self.ioloop = IOLoop.current()
            self.ping = Ping(io_loop=self.ioloop)
            self.jobs = jobs
            self.queue = tornado.queues.Queue(self.jobs)
            for i in range(self.jobs):
                self.ioloop.spawn_callback(self.ping_worker)
            self.ioloop.run_sync(self.ping_task)

            # @todo: Add community oid check
            # self.addresses = set()

            # snmp
            self.ioloop = IOLoop.current()
            self.jobs = jobs
            # self.convert = convert
            self.queue = tornado.queues.Queue(self.jobs)

            for i in range(self.jobs):
                self.ioloop.spawn_callback(self.poll_worker, community, oid, timeout, self.version)
            self.ioloop.run_sync(self.poll_task)

        for x in self.enable_ping:
            x2 = "Да"
            x4 = x5 = x6 = x7 = x8 = x9 = x11 = "Не определено"
            if x in self.hosts_enable:
                x3 = "Да"
                x8 = self.mo[x]["name"]
                x11 = self.mo[x]["is_managed"]
                if self.mo[x]["tags"]:
                    x9 = ",".join(self.mo[x]["tags"] if self.mo[x]["tags"] else [])
            else:
                x3 = "Нет"
            if x in self.enable_snmp:
                # ['1.3.6.1.2.1.1.2.0', '1.3.6.1.2.1.1.5.0']
                try:
                    x5 = sysObjectId = self.snmp[x]["1.3.6.1.2.1.1.2.0"]
                    for p in Platform.objects.filter(snmp_sysobjectid=x5):
                        if p:
                            x6 = p.vendor
                            x7 = p.name
                except:
                    x5 = "Не определено"
                try:
                    sysname = self.snmp[x]["1.3.6.1.2.1.1.5.0"]
                    x4 = sysname
                except:
                    x4 = "Не определено"
            s = ";".join(
                [
                    x,
                    str(x2),
                    str(x3),
                    str(x11),
                    str(x4),
                    str(x5),
                    str(x6),
                    str(x7),
                    str(x8),
                    pool,
                    str(x9),
                ]
            ).decode("utf-8", "ignore")
            # print s
            data += s + "\n"
            # file.write(s + "\n")
        print data

    @tornado.gen.coroutine
    def ping_task(self):
        with open(self.ff) as f:
            for line in f:
                line = line.strip()
                yield self.queue.put(line)
        # for a in self.addresses:
        #    yield self.queue.put(a)
        for i in range(self.jobs):
            yield self.queue.put(None)
        yield self.queue.join()

    @tornado.gen.coroutine
    def ping_worker(self):
        while True:
            a = yield self.queue.get()
            if a:
                rtt, attempts = yield self.ping.ping_check_rtt(a, count=1, timeout=1000)
                if rtt:
                    #   self.stdout.write("%s %.2fms\n" % (a, rtt * 1000))
                    self.enable_ping.add(a)
                    # else:
                    #   self.stdout.write("%s FAIL\n" % a)
                    # self.not_ping.add(a)
            self.queue.task_done()
            if not a:
                break

    @tornado.gen.coroutine
    def poll_task(self):
        for a in self.enable_ping:
            yield self.queue.put(a)
        for i in range(self.jobs):
            yield self.queue.put(None)
        yield self.queue.join()

    @tornado.gen.coroutine
    def poll_worker(self, community, oid, timeout, version):
        while True:
            a = yield self.queue.get()
            if a:
                for c in community:
                    for ver in version:
                        # t0 = perf_counter()
                        try:
                            r = yield snmp_get(
                                address=a,
                                oids=dict((k, k) for k in oid),
                                community=c,
                                version=ver,
                                timeout=timeout,
                            )
                            s = "OK"
                            # dt = perf_counter() - t0
                            mc = c
                            self.enable_snmp.add(a)
                            self.snmp[a] = r
                            self.snmp[a]["version"] = ver
                            self.snmp[a]["community"] = c
                            break
                        except SNMPError as e:
                            s = "FAIL"
                            r = str(e)
                            # dt = perf_counter() - t0
                            mc = ""
                        except Exception as e:
                            s = "EXCEPTION"
                            r = str(e)
                            # dt = perf_counter() - t0
                            mc = ""
                            break

            self.queue.task_done()
            if not a:
                break

if __name__ == "__main__":
    Command().run()
