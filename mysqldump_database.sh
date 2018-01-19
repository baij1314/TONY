#!/bin/bash
# 2018年1月19日17:24:01

mysql -uroot -p123456 -e "show databases;"|sed '1d'
read -p "输入要备份的数据库" DB
[ ! -d /backup ]&&mkdir -p /backup
mysqldump -uroot -p123456  --all-${DB} |gzip >/backup/${DB}_`date '+%m-%d-%Y'`.sql.gz
