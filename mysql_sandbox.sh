########## STANDALONE MYSQL SANDBOXES ##########

# see how it hangs
# I have still not debugged why, yet, so it's useful to know that we can directly assign a custom port number we want.
# this can be changed afterwards with the ./change_ports <port_#> script in the sandbox directory.
make_sandbox --add_prefix=rm_0_ /opt/percona_server/5.7.17  -- --check_port

# use custom port
make_sandbox --add_prefix=rm_1_ /opt/percona_server/5.7.17  -- --sandbox_port=12440

# no prompt for confirmation but shows options used
make_sandbox --add_prefix=rm_2_ /opt/percona_server/5.7.17  -- --sandbox_port=12441 \
  --no_confirm

# no prompt for confirmation and no options used shown
make_sandbox --add_prefix=rm_3_ /opt/percona_server/5.7.17  -- --sandbox_port=12442 \
  --no_show

# stops the server, if it was started after loading the grants
make_sandbox --add_prefix=rm_4_ /opt/percona_server/5.7.17  -- --sandbox_port=12443 \
  --no_show --no_run

# add variables to be used on the my.sandbox.cnf file
make_sandbox --add_prefix=rm_5_ /opt/percona_server/5.7.17  -- --sandbox_port=12444 \
  --no_show \
  -c innodb_file_per_table=0 \
  -c innodb_file_format=Antelope

# add many variables to be used on the my.sandbox.cnf file
make_sandbox --add_prefix=rm_6_ /opt/percona_server/5.7.17  -- --sandbox_port=12445 \
  --no_show -c \
"
innodb_file_per_table=0
innodb_file_format='Antelope'
loose-any_other_variable_here=32M

# even with a comment and a new line :)
loose-another_variable
"

########## REPLICATION MYSQL SANDBOXES ##########

# use custom directory, and base port for sandboxes
make_replication_sandbox --replication_directory=repl_rm_7_ --sandbox_base_port=12446 \
  /opt/percona_server/5.7.17 

# with only one slave
make_replication_sandbox --replication_directory=repl_rm_8_ --sandbox_base_port=12449 \
  --how_many_slaves=1 \
  /opt/percona_server/5.7.17 

# master-master
# for some reason it starts nodes starting from sandbox_base_port+1 (bug?)
make_replication_sandbox --replication_directory=repl_rm_9_ --sandbox_base_port=12451 \
  --master_master \
  /opt/percona_server/5.7.17 

# 4-node ring
# for some reason it starts nodes starting from sandbox_base_port+1 (bug?)
make_replication_sandbox --replication_directory=repl_rm_10_ --sandbox_base_port=12454 \
  --circular=4 \
  /opt/percona_server/5.7.17 

# setting master options
make_replication_sandbox --replication_directory=repl_rm_11_ --sandbox_base_port=12459 \
  --how_many_slaves=1 \
  --master_options="-c innodb_file_per_table=0 -c innodb_file_format=Antelope" \
  /opt/percona_server/5.7.17 

# setting slave options. Important for tools like pt-table-checksum to work properly
make_replication_sandbox --replication_directory=repl_rm_12_ --sandbox_base_port=12461 \
  --how_many_slaves=1 \
  --slave_options="-c report-host=127.0.0.1" \
  /opt/percona_server/5.7.17 

# setting slave options. Important for tools like pt-table-checksum to work properly
make_replication_sandbox --replication_directory=repl_rm_13_ --sandbox_base_port=12463 \
  --how_many_slaves=2 \
  --one_slave_options="1:-c report-host=custom_host_1" \
  --one_slave_options="2:-c report-host=custom_host_2" \
  /opt/percona_server/5.7.17 


# check ports used
sudo netstat -punta | grep 124 | cut -d ':' -f 2 | cut -d " " -f 1 | sort | uniq | grep 124

sudo netstat -punta | grep 124 | cut -d ':' -f 2 | cut -d " " -f 1 | sort | uniq


# stop and remove all *_rm_* sandboxes in the directory
cd $HOME/sandboxes/
for tmpsand in `ls -d ./*_rm_*`; do
  echo $tmpsand;
  $tmpsand/stop || $tmpsand/stop_all;
  rm -rf $tmpsand;
done;

