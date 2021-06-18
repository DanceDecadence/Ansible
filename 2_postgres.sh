#!/bin/bash

### Check for root or sudo ###

if [ $(id -u) != 0 ]
then
echo " --- Execute with root or sudo --- "
exit 1
fi


### Search for initdb ###

INITDB=$(find / -name initdb)

if [ "$INITDB" = "" ]
then
echo "Install postgresql first"
exit 2
fi

echo "initdb location is: $INITDB"


### Read PGDATA path ###

echo "Choose root directory for postgres [default path is /data/postgres/12/data]: "
read PGDATA

if [ "$PGDATA" = "" ]
then
PGDATA=/data/postgres/12/data/
fi


### Create PGDATA folder ###

mkdir -p $PGDATA
chown -R postgres:postgres $PGDATA
chmod -R 0750 $PGDATA

echo "pgdata location is: $PGDATA"


### Change PGDATA in bash profile of postgres user ###

echo "[ -f /etc/profile ] && source /etc/profile" > /var/lib/pgsql/.bash_profile
echo "PGDATA=$PGDATA" >> /var/lib/pgsql/.bash_profile
echo "export PGDATA" >> /var/lib/pgsql/.bash_profile


### initialize DB cluster ###

su - postgres -c "$INITDB -D $PGDATA"
su - postgres -c "/usr/pgsql-12/bin/pg_ctl -D $PGDATA -l logfile start"
/usr/pgsql-12/bin/postgresql-12-setup initdb
pkill -u postgres
systemctl enable postgresql-12
systemctl start


### Read allowed subnet ###

echo "Enter allowed subnet to access DB [192.168.0.0/24]: "
read allowed_subnet

if [ "$allowed_subnet" = "" ] 
then 
allowed_subnet='192.168.0.0/24'
fi


# Add subnet to pg_hba.conf
echo "host	all 		all 		${allowed_subnet} 		md5" >> $(find $PGDATA -name pg_hba.conf)
