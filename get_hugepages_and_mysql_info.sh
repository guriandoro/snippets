#!/bin/bash
# This script will gather data on HugePages and MySQL (InnoDB buffer pool)


echo "###############################"
cat /proc/meminfo | egrep -i "page|huge"
echo "###############################"
echo
mysql -Be "SELECT round(@@global.innodb_buffer_pool_size/1024/1024) AS InnoDB_BP_size"
mysql -Be "SELECT @@global.innodb_buffer_pool_instances AS InnoDB_BP_instances"
mysql -Be "SELECT round(@@global.innodb_buffer_pool_chunk_size/1024/1024) AS InnoDB_BP_chunk_size"
echo "###############################"
echo

HP_TOTAL=`cat /proc/meminfo | grep -i pages | grep HugePages_Total | awk '{print $2}'`
HP_FREE=`cat /proc/meminfo | grep -i pages | grep HugePages_Free | awk '{print $2}'`
HP_RSVD=`cat /proc/meminfo | grep -i pages | grep HugePages_Rsvd | awk '{print $2}'`
HP_SIZE=`cat /proc/meminfo | grep -i pages | grep Hugepagesize | awk '{print $2}'`

echo -e "total:\t$HP_TOTAL\tfree:\t$HP_FREE\treserved:\t$HP_RSVD"
echo -e "page size:\t$HP_SIZE"
echo
echo -e "HP pool size:\t$((($HP_TOTAL)*$HP_SIZE/1024)) Mb"
echo -e "committed:\t$((($HP_TOTAL-$HP_FREE+$HP_RSVD)*$HP_SIZE/1024)) Mb"

exit 0
