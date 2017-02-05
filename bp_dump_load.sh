#!/bin/bash

# To be used with a mysql sandbox (for now).

# Query to check on pages loaded in BP for tables like joinit*
# SELECT BP.SPACE, T.NAME, count(BP.PAGE_NUMBER)
# FROM INFORMATION_SCHEMA.INNODB_SYS_TABLES as T
# JOIN INFORMATION_SCHEMA.INNODB_BUFFER_PAGE as BP
# USING(SPACE)
# WHERE T.NAME LIKE 'test/joinit%'
# GROUP BY BP.SPACE;


./restart

./use -B -e "show status like 'innodb_buffer%';" > 1_initial_BP_status.out
 
echo LOADING FIRST TABLE WITH DATA;

#LOAD FIRST TABLE WITH DATA
./use test -e "DROP TABLE IF EXISTS joinit";
./use test -e "CREATE TABLE joinit (i int(11) NOT NULL AUTO_INCREMENT,s varchar(64) DEFAULT NULL,t time NOT NULL,g int(11) NOT NULL,PRIMARY KEY (i)) ENGINE=InnoDB  DEFAULT CHARSET=latin1";
./use test -e "INSERT INTO joinit VALUES (NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )));"
for i in `seq 26`; do
./use test -e "INSERT INTO joinit SELECT NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )) FROM joinit;";
done
#END LOAD FIRST TABLE WITH DATA


./use -B -e "show status like 'innodb_buffer%';" > 2_BP_status_after_first_table.out


echo DUMPING BUFFER POOL
#BP DUMP
./use -e "SET @@GLOBAL.innodb_buffer_pool_dump_now = 1;"

echo SLEEPING FOR 60 SECONDS FOR BP DUMP
sleep 60;

./use -e "SHOW STATUS LIKE 'innodb_buffer%';" > 3_BP_status_after_BP_dump.out


echo LOADING SECOND TABLE WITH DATA;

#LOAD SECOND TABLE WITH DATA
./use test -e "DROP TABLE IF EXISTS joinit_2";
./use test -e "CREATE TABLE joinit_2 (i int(11) NOT NULL AUTO_INCREMENT,s varchar(64) DEFAULT NULL,t time NOT NULL,g int(11) NOT NULL,PRIMARY KEY (i)) ENGINE=InnoDB  DEFAULT CHARSET=latin1";
./use test -e "INSERT INTO joinit_2 VALUES (NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )));"
for i in `seq 26`; do
./use test -e "INSERT INTO joinit_2 SELECT NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )) FROM joinit_2;";
done
#END LOAD SECOND TABLE WITH DATA

./use -B -e "show status like 'innodb_buffer%';" > 4_BP_status_after_second_table.out


#BP LOAD
./use -e "SET @@GLOBAL.innodb_buffer_pool_load_now = 1;"

echo SLEEPING FOR 60 SECONDS FOR BP LOAD
sleep 60;

./use -e "SHOW STATUS LIKE 'innodb_buffer%';" > 5_BP_status_after_BP_load.out

exit 0;




#############################
#Adding more tests here, after the script exit, until I have time to edit this into the file.
#############################

./restart

./use -B -e "show status like 'innodb_buffer%';" > 1_initial_BP_status.out
 
echo LOADING TABLES WITH DATA;

echo LOAD FIRST TABLE WITH DATA
./use test -e "DROP TABLE IF EXISTS joinit";
./use test -e "CREATE TABLE joinit (i int(11) NOT NULL AUTO_INCREMENT,s varchar(64) DEFAULT NULL,t time NOT NULL,g int(11) NOT NULL,PRIMARY KEY (i)) ENGINE=InnoDB  DEFAULT CHARSET=latin1";
./use test -e "INSERT INTO joinit VALUES (NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )));"
for i in `seq 26`; do
./use test -e "INSERT INTO joinit SELECT NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )) FROM joinit;";
done
#END LOAD FIRST TABLE WITH DATA

echo LOAD SECOND TABLE WITH DATA
./use test -e "DROP TABLE IF EXISTS joinit_2";
./use test -e "CREATE TABLE joinit_2 (i int(11) NOT NULL AUTO_INCREMENT,s varchar(64) DEFAULT NULL,t time NOT NULL,g int(11) NOT NULL,PRIMARY KEY (i)) ENGINE=InnoDB  DEFAULT CHARSET=latin1";
./use test -e "INSERT INTO joinit_2 VALUES (NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )));"
for i in `seq 21`; do
./use test -e "INSERT INTO joinit_2 SELECT NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )) FROM joinit_2;";
done
#END LOAD SECOND TABLE WITH DATA


echo LOAD THIRD TABLE WITH DATA
./use test -e "DROP TABLE IF EXISTS joinit_3";
./use test -e "CREATE TABLE joinit_3 (i int(11) NOT NULL AUTO_INCREMENT,s varchar(64) DEFAULT NULL,t time NOT NULL,g int(11) NOT NULL,PRIMARY KEY (i)) ENGINE=InnoDB  DEFAULT CHARSET=latin1";
./use test -e "INSERT INTO joinit_3 VALUES (NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )));"
for i in `seq 19`; do
./use test -e "INSERT INTO joinit_3 SELECT NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )) FROM joinit_3;";
done
#END LOAD SECOND TABLE WITH DATA


echo DUMPING BUFFER POOL
#BP DUMP
./use -e "SET @@GLOBAL.innodb_buffer_pool_dump_now = 1;"


./use test -e "SELECT COUNT(*) FROM joinit;" # WHERE i < 1000000";

./use test -e "UPDATE joinit_3 SET t=now()";

./use test -e "INSERT INTO joinit_2 SELECT NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )) FROM joinit_2;";


SELECT BP.SPACE, T.NAME, count(BP.PAGE_NUMBER)
FROM INFORMATION_SCHEMA.INNODB_SYS_TABLES as T
JOIN INFORMATION_SCHEMA.INNODB_BUFFER_PAGE as BP
USING(SPACE)
WHERE T.NAME LIKE 'test/joinit%'
GROUP BY BP.SPACE;


./use -B -e "show status like 'innodb_buffer%';" > 2_BP_status_after_first_table.out


echo DUMPING BUFFER POOL
#BP DUMP
./use -e "SET @@GLOBAL.innodb_buffer_pool_dump_now = 1;"

echo SLEEPING FOR 60 SECONDS FOR BP DUMP
sleep 60;

./use -e "SHOW STATUS LIKE 'innodb_buffer%';" > 3_BP_status_after_BP_dump.out


echo LOADING SECOND TABLE WITH DATA;

#LOAD SECOND TABLE WITH DATA
./use test -e "DROP TABLE IF EXISTS joinit_2";
./use test -e "CREATE TABLE joinit_2 (i int(11) NOT NULL AUTO_INCREMENT,s varchar(64) DEFAULT NULL,t time NOT NULL,g int(11) NOT NULL,PRIMARY KEY (i)) ENGINE=InnoDB  DEFAULT CHARSET=latin1";
./use test -e "INSERT INTO joinit_2 VALUES (NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )));"
for i in `seq 26`; do
./use test -e "INSERT INTO joinit_2 SELECT NULL, uuid(), time(now()),  (FLOOR( 1 + RAND( ) *60 )) FROM joinit_2;";
done
#END LOAD SECOND TABLE WITH DATA

./use -B -e "show status like 'innodb_buffer%';" > 4_BP_status_after_second_table.out


#BP LOAD
./use -e "SET @@GLOBAL.innodb_buffer_pool_load_now = 1;"

echo SLEEPING FOR 60 SECONDS FOR BP LOAD
sleep 60;

./use -e "SHOW STATUS LIKE 'innodb_buffer%';" > 5_BP_status_after_BP_load.out

exit;


