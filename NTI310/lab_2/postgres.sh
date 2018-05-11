#!/bin/bash

# set variables first (faster)
echo "Please enter your new database password (also used as 'postgres' users' password for phpPgAdmin):"
read db_password

# contains the extra packages that we need
yum install -y epel-release
# postgres components
yum install -y python-pip python-devel gcc postgresql-server postgresql-devel postgresql-contrib

postgresql-setup initdb

# start postgresql now and start it at boot
systemctl start postgresql && systemctl enable postgresql

echo "CREATE DATABASE myproject;
CREATE USER myprojectuser WITH PASSWORD '$db_password';
ALTER ROLE myprojectuser SET client_encoding TO 'utf8';
ALTER ROLE myprojectuser SET default_transaction_isolation TO 'read committed';
ALTER ROLE myprojectuser SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE myproject TO myprojectuser;" > /tmp/myproject.sql
# used in our script to input our newly coded db (above) as the postgres user
sudo -i -u postgres psql -U postgres -f /tmp/myproject.sql
rm -f /tmp/myproject.sql

# install the web frontend
yum -y install phpPgAdmin

# allow host access from any IP
sed -i.bak 's,Require local,Require all granted,g' /etc/httpd/conf.d/phpPgAdmin.conf

# add postgres password, which is $db_password
echo "ALTER USER postgres WITH PASSWORD '$db_password';" > /tmp/postgres_user.sql
sudo -i -u postgres psql -U postgres -f /tmp/postgres_user.sql
rm -f /tmp/postgres_user.sql

# disable extra login security for web access
sed -i "s,\$conf\['extra_login_security'\] = true;,\$conf\['extra_login_security'\] = false;,g" /etc/phpPgAdmin/config.inc.php

# set md5 authentication
sed -i.bak -r 's,ident|peer,md5,g' /var/lib/pgsql/data/pg_hba.conf

# restart postgres & enable apache for start @ boot
systemctl enable httpd && systemctl start httpd
systemctl reload postgresql

setenforce 0 # set selinux to permissive now
sed -i 's,SELINUX=enforcing,SELINUX=disabled,g' /etc/sysconfig/selinux # don't load an selinux policy on boot
