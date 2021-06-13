#!/bin/bash

echo "This script will helps you to configure postgres"

# Check for root or sudo
#if [[ $(id -u) -ne 0 ]]
#then
#echo " --- Execute with root or sudo --- "
#exit 1
#fi

# Read PGDATA path
echo "Choose root directory for postgres (default path is /data/postgres/12/data/): "
read PGDATA

if [ $PGDATA="" ]
then
PGDATA="/data/postgres/12/data/"
fi

echo PGDATA=$PGDATA

# Make directory for PGDATA
mkdir -p $PGDATA
chown postgres:postgres $PGDATA
chmod -R go-rwx $PGDATA

# Change .bash_profile of postgres user
echo "[ -f /etc/profile ] && source /etc/profile" > '/var/lib/pgsql/.bash_profile'
echo "PGDATA=${PGDATA}" >> '/var/lib/pgsql/.bash_profile'
echo "export PGDATA" >> '/var/lib/pgsql/.bash_profile'

# INIT DB
#su -c "${INITDB} --pwprompt -D ${PGDATA}" postgres
su -c /usr/pgsql-12/bin/initdb postgres


# Allowed subnet to connect from
#echo "Enter allowed subnet to access DB (default it 192.168.0.0/24): "
#read allowed_subnet

#if [[ $allowed_subnet = "" ]]
#then
#allowed_subnet='192.168.0.0/24'
#fi

# Add allowed subnet on configuration
#echo "host all all ${allowed_subnet} md5" >> $PGDATA'pg_hba.conf'
