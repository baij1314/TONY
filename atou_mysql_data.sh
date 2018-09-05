#!/bin/sh
#mysql backup
find  /www/backup/ -name '*.sql'   -type f -mtime  +30 -exec rm -rf {} \;
MYUSER=script_user
export MYSQL_PWD=123123
mysql -e "show databases;" -u$MYUSER -p$MYSQL_PWD | egrep -vi "Data|_schema|mysql|test|job|order" | xargs mysqldump -u$MYUSER -p$MYSQL_PWD --databases > /www/backup/mysql_$(date +%F)_dump.all.sql

#dell 30 day   mpurse logs  
find  /opt/tomcat/  -name '*.log'    -type f -mtime  +30 -exec rm -rf {} \;
find  /opt/tomcat/ -name '*.log.*'   -type f -mtime  +15 -exec rm -rf {} \;

#MYUSER=root
#MYSQL_PWD=123123
#SOCKET=/var/lib/mysql/mysql.sock
#MYBAKDIR=/www/backup/mysql$(date +%F)
#MYLOGIN="mysql -u$MYUSER -p$MYSQL_PWD -S $SOCKET"
#MYDUMP="mysqldump -u$MYUSER -p$MYSQL_PWD -S$SOCKET -B"
#SHOW=$MYLOGIN -e "show databases;"
#DATABASE="$($MYLOGIN -e "show databases;"|egrep -vi "Data|_schema|mysql")"
#for dbname in $DATABASE
#  do
#   MYDIR=/$MYBAKDIR/$dbname
#   [ ! -d $MYDIR ] && mkdir -p $MYDIR
# $MYDUMP $dbname >$MYDIR/${dbname}.sql
#done
