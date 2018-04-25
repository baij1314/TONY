#!/bin/sh
echo -n  "please mysql password  ->"
read -s  PASSWD
MYUSER=root
MYPASS=$PASSWD
SOCKET=/www/mysql/mysql.sock
MYBAKDIR=/www/backup
MYLOGIN="mysql -u$MYUSER -p$MYPASS -S $SOCKET"
MYDUMP="mysqldump -u$MYUSER -p$MYPASS -S$SOCKET -B"
SHOW=$MYLOGIN -e "show databases;"
DATABASE="$($MYLOGIN -e "show databases;"|egrep -vi "Data|_schema|mysql")"
echo $DATABASE 
for dbname in $DATABASE
  do
   MYDIR=/$MYBAKDIR/$dbname
   [ ! -d $MYDIR ] && mkdir -p $MYDIR
 $MYDUMP $dbname|gzip >$MYDIR/${dbname}_$(date +%F).sql.gz
done
ls -l  $MYBAKDIR