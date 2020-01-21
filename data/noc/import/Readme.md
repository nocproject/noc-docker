Readme
-------

If you need import list of you host in NOC.
 
First - you need copy file
*sa.managedobject.csv.example* to *sa.managedobject.csv*. 
Second - add you host with NAME,IP,LOGIN,PASSWORD,SNMP community, etc in 
*sa.managedobject.csv*

then run 
~~~
docker-compose up import-default
~~~