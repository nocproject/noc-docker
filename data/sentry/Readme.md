Setup Sentry
----

You need set passwords for Sentry in *sentry.env* file.
```
SENTRY_SECRET_KEY="<password from sentry>"
SENTRY_DB_PASSWORD="<password from PG sentry DB>"
```
Script *pre.sh* generate random password when start with *all* or *sentry*

```
./pre.sh all
or
./pre.sh sentry
```
