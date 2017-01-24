#!/bin/bash

# To be used with a mysql sandbox (for now).

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
