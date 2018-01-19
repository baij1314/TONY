#!/bin/bash
#2018年1月19日17:03:55
#CHENYU
Menu(){
	echo "请选择主或从"
	echo " sh $0 1|2 "
	echo " 1是主|2是从"
	exit
}
###Master Config Mysql
Master(){
	cat >/etc/my.cnf<<EOF
	[mysqld]
	datadir=/var/lib/mysql
	socket=/var/lib/mysql/mysql.sock
	user=mysql
	symbolic-links=0
	log-bin=mysql-bin
	server-id = 1
	auto_increment_offset=1
	auto_increment_increment=2
	[mysqld_safe]
	log-error=/var/log/mysqld.log
	pid-file=/var/run/mysqld/mysqld.pid
EOF
/etc/init.d/mysqld restart
mysql -uroot -p123456 -e "grant  replication  slave  on *.* to  'tongbu'@'%'  identified by  '123456'；"
ifconfig eth0|grep "Bcast"|awk '{print $2}'|awk -F":" '{print "Master "$2}'
mysql -uroot -p123456 -e "show master status;"|tail -1|awk '{print "M_FIL:  "$1}'
mysql -uroot -p123456 -e "show master status;"|tail -1|awk '{print "M_POS:  "$2}'
}

#Slave Config Mysql
Slave(){
	read -p "Please Input Master IPaddr: " M_IP
	read -p "Please Input M_FIL: " M_FIL
	read -p "Please Input M_POS: " M_POS
	sed -i 's#server-id = 1#server-id = 2#g' /etc/my.cnf
	sed -i '/log-bin=mysql-bin/d' /etc/my.cnf
	/etc/init.d/mysqld restart
	mysql -uroot -p123456 -e "change master to master_host='$M_IP',master_user='tongbu',master_password='123456',master_log_file='$MASTER_FILE',master_log_pos=$MASTER_POS；"
	mysql -uroot -p123456 -e "slave start;show slave status\G;"
}
[ $# -eq 0 ]&&Menu
[ $1 -eq 1 ]&&Master
[ $1 -eq 2 ]&&Slave
