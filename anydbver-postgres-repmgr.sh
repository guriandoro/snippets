# PG repmgr

./anydbver deploy \
  node0 pg:13 hn:postgres0 pgbackrest \
  node1 pg:13 hn:postgres1 master:node0 pgbackrest \
  node2 pg:13 hn:postgres2 master:node0 pgbackrest

for i in 0 1 2; do 
  ./anydbver mount /tmp/ node$i:/nfs; 
  ./anydbver ssh node$i 'yum -y install repmgr13 rsync vim less'
done

#### SETUP PRIMARY NODE
#######################

./anydbver ssh node0

cat <<'EOF' >/etc/pgbackrest.conf
[global]
repo1-path=/nfs/pgbackups/pgbackrest
repo1-retention-full=2
[pg0app]
pg1-path=/var/lib/pgsql/13/data
pg1-port=5432
EOF
# sudo -u postgres pgbackrest stanza-create --stanza=pg0app --log-level-console=info
# sudo -u postgres pgbackrest check --stanza=pg0app --log-level-console=info
# sudo -u postgres pgbackrest backup --stanza=pg0app --log-level-console=info
# sudo -u postgres pgbackrest info --log-level-console=info
# sudo -u postgres pgbackrest restore --stanza=pg0app --log-level-console=info

#chown postgres:postgres /nfs/pgbackups/pgbackrest
#rm -rf /nfs/pgbackups/pgbackrest*
sudo -u postgres pgbackrest stanza-create --stanza=pg0app --log-level-console=info
sudo -u postgres pgbackrest backup --stanza=pg0app --log-level-console=info

cat <<'EOF' >./repmgr_psql.sql
CREATE USER repmgr WITH SUPERUSER PASSWORD 'secret';
ALTER USER repmgr SET search_path TO repmgr, "$user", public;
CREATE DATABASE repmgr OWNER repmgr;
ALTER SYSTEM SET shared_preload_libraries=repmgr;
ALTER SYSTEM SET archive_mode = on;
ALTER SYSTEM SET archive_command = 'pgbackrest --stanza=pg0app archive-push %p';
ALTER SYSTEM SET restore_command = 'pgbackrest --stanza=pg0app archive-get %f %p';
EOF
psql -f ./repmgr_psql.sql

cat <<'EOF' >>/var/lib/pgsql/13/data/pg_hba.conf
host    repmgr        repmgr      0.0.0.0/0          md5
EOF

systemctl restart postgresql-13.service

cat <<EOF >>/etc/repmgr/13/repmgr.conf
node_id=1
node_name='pg0'
conninfo='host=postgres0 user=repmgr dbname=repmgr password=secret connect_timeout=2'
data_directory='/var/lib/pgsql/13/data'
EOF

sudo -u postgres /usr/pgsql-13/bin/repmgr -f /etc/repmgr/13/repmgr.conf primary register
sudo -u postgres /usr/pgsql-13/bin/repmgr -f /etc/repmgr/13/repmgr.conf cluster show

exit

#### SETUP FIRST REPLICA NODE
#############################

./anydbver ssh node1

cat <<'EOF' >/etc/pgbackrest.conf
[global]
repo1-path=/nfs/pgbackups/pgbackrest
repo1-retention-full=2
[pg0app]
pg1-path=/var/lib/pgsql/13/data
pg1-port=5432
EOF

cat <<EOF >>/etc/repmgr/13/repmgr.conf
node_id=2
node_name='pg1'
conninfo='host=postgres1 user=repmgr dbname=repmgr password=secret connect_timeout=2'
data_directory='/var/lib/pgsql/13/data'
EOF

systemctl stop postgresql-13.service
rm -rf /var/lib/pgsql/13/data/*
sudo -u postgres PGPASSWORD=secret /usr/pgsql-13/bin/repmgr -h postgres0 -U repmgr -d repmgr -f /etc/repmgr/13/repmgr.conf standby clone
systemctl start postgresql-13.service
tail /var/lib/pgsql/13/data/log/postgresql-*.log
sudo -u postgres /usr/pgsql-13/bin/repmgr -f /etc/repmgr/13/repmgr.conf standby register
sudo -u postgres /usr/pgsql-13/bin/repmgr -f /etc/repmgr/13/repmgr.conf cluster show

exit

#### SETUP SECOND REPLICA NODE
##############################

./anydbver ssh node2

cat <<'EOF' >/etc/pgbackrest.conf
[global]
repo1-path=/nfs/pgbackups/pgbackrest
repo1-retention-full=2
[pg0app]
pg1-path=/var/lib/pgsql/13/data
pg1-port=5432
EOF

cat <<EOF >>/etc/repmgr/13/repmgr.conf
node_id=3
node_name='pg2'
conninfo='host=postgres2 user=repmgr dbname=repmgr password=secret connect_timeout=2'
data_directory='/var/lib/pgsql/13/data'
EOF

systemctl stop postgresql-13.service
rm -rf /var/lib/pgsql/13/data/*
sudo -u postgres PGPASSWORD=secret /usr/pgsql-13/bin/repmgr -h postgres0 -U repmgr -d repmgr -f /etc/repmgr/13/repmgr.conf standby clone
systemctl start postgresql-13.service
tail /var/lib/pgsql/13/data/log/postgresql-*.log
sudo -u postgres /usr/pgsql-13/bin/repmgr -f /etc/repmgr/13/repmgr.conf standby register
sudo -u postgres /usr/pgsql-13/bin/repmgr -f /etc/repmgr/13/repmgr.conf cluster show

exit
