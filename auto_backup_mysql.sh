#!/bin/bash 
#auto backup mysql
#By author jfedu.net 2017
#Define PATH定义变量
BAKDIR=/data/backup/`date +%Y-%m-%d`
MYSQLDB=$*
MYSQLUSR=backup
MYSQLPW=123456
#must use root user run scripts 必须使用root用户运行，$UID为系统变量
if [ $UID -ne 0 ];then
   echo This script must use the root user !
   sleep 2
   exit 0
fi
if [ $# -eq 0 ];then
        echo -e "\033[32m---------------------\033[0m"
        echo -e "\033[32mUsage:{Please Enter Backup DB,sh $0 jd|baidu|jfedu|all}\033[0m"
        exit 0
fi
#Define DIR and mkdir DIR 判断目录是否存在，不存在则新建
if
   [ ! -d  $BAKDIR ];then
   mkdir  -p  $BAKDIR
fi

if [ $1 == "all" ];then
	/usr/bin/mysqldump -u$MYSQLUSR -p$MYSQLPW --all-databases >$BAKDIR/ALL_DB.sql
	echo "--------------"
	echo  "The $BAKDIR/ALL_DB.sql Mysql  Database backup successfully "
else
	for i in `echo $MYSQLDB`
	do
		/usr/bin/mysqldump -u$MYSQLUSR -p$MYSQLPW -d $i >$BAKDIR/${i}.sql
		echo "--------------"
		echo  "The $BAKDIR/${i}.sql Mysql  Database backup successfully "
	done
fi
