#!/bin/bash
#2018年1月19日11:23:54
#CHENYU
USE=$1
PASSWD=$2
DB_USE=$3
IP=192.168.1.70
AIR(){
        echo "Enter mysql:sh $0 use passwd db_user|root 123456 bbs"
        echo "   输入数据: sh $0 用户 密码 mysql用户|root 123456 bbs"
        exit 0
}
GRANT(){
        mysql -u$USE -p$PASSWD -e "grant all on *.* to  $DB_USE@'$IP' identified by '$PASSWD'; flush privileges;"
}
SHOW(){
        mysql -u$USE -p$PASSWD -e " show grants for $DB_USE@'$IP';"
}
[ $# -eq 0 ]&&AIR
[ $# -gt 2 ]&&GRANT&&SHOW
