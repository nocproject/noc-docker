Readme
-------

If you need import list of you host in NOC.
 
First - you need copy file
*sa.managedobject.csv.example* to *sa.managedobject.csv*. 
Second - add you host with NAME,IP,LOGIN,PASSWORD,SNMP community, etc in 
*sa.managedobject.csv*
```shell script
cd ./data/noc/import
cp sa.managedobject.csv.example sa.managedobject.csv
```



then run 
~~~
docker-compose -f docker-compose-addhosts.yml run --rm import-default
~~~
existing records are updated


Manual method
----
Open `Main/setup/CSV Import/Export` in NOC menu or

```djangourlpath
https://0.0.0.0/#main.csv
```

Choice `sa.managedobject` and upload you .csv file with host records. 
