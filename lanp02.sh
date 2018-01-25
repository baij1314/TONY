#!/bin/bash

###################  http-2.2.34
H_URL=http://mirrors.hust.edu.cn/apache/httpd/
H_FID=httpd-2.2.34
H_FIX=/usr/local/apache2
#############  PHP5.3
P_DIR=php-5.3.28
P_URL=http://mirrors.sohu.com/php/
P_FIX=/usr/local/php5
###############  MySQL define path variable
M_DIR=mysql-5.5.20
M_URL=http://down1.chinaunix.net/distfiles/
M_FIX=/usr/local/mysql
Httpd(){
	#install httpd
	yum install gcc gcc-c++  apr  apr-* zlib-devel -y
	[ ! -f ${H_FID}.tar.gz  ]&&wget -c $H_URL${H_FID}.tar.gz
	[ ! -d $H_FID ]&&rm -rf $H_FID
	tar xzf ${H_FID}.tar.gz&&cd $H_FID
	./configure --prefix=$H_FIX \
	--with-mpm=prefork \
	--enable-so \
	--enable-rewrite \
	--enable-mods-shared=all \
	--enable-nonportable-atomics=yes \
	--disable-dav \
	--enable-deflate \
	--enable-cache \
	--enable-disk-cache \
	--enable-mem-cache \
	--enable-file-cache
	[ $? -ne 0 ]&&exit 0
	make&&make install
	\cp support/apachectl /etc/init.d/httpd
	chmod u+x /etc/init.d/httpd
	/etc/init.d/httpd start >/dev/null
	[ `netstat -lnt|grep 80|wc -l` -ne 0 ]&&echo   "install Apache2.2 OK"
}
Php(){
	############  php ################
	#install php
	[ ! -f ${P_DIR}.tar.bz2 ]&&wget -c $P_URL${P_DIR}.tar.bz2
	[ ! -d ${P_DIR} ]&&tar xf ${P_DIR}.tar.bz2
	yum install ncurses-devel  bison  libxml2* -y
	cd ${P_DIR}
	./configure --prefix=$P_FIX  --with-config-file-path=/usr/local/php5/etc   --with-apxs2=/usr/local/apache2/bin/apxs  --with-mysq
	l=/usr/local/mysql55/
	[ $? -ne 0 ]&&exit 1
	make&&make install
	#PHPinfo测试页面
	echo "AddType     application/x-httpd-php .php" >>$H_FIX/conf/httpd.conf
	[ ! -f $H_FIX/htdocs/index.php ]&&echo '<?php phpinfo(); ?>' >$H_FIX/htdocs/index.php
}
Mysql(){
	[ `grep "mysql" /etc/passwd|wc -l` -eq 0 ]&&useradd -s /sbin/nologin mysql
	[ ! -f ${M_DIR}.tar.gz  ]&&wget -c $M_URL${M_DIR}.tar.gz
	[ ! -d $M_DIR ]&&rm -rf $M_DIR
	tar xf ${M_DIR}.tar.gz&&cd $M_DIR
	yum install cmake ncurses-devel -y
	cmake . -DCMAKE_INSTALL_PREFIX=$M_FIX \
	-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
	-DMYSQL_DATADIR=/data/mysql \
	-DSYSCONFDIR=/etc \
	-DMYSQL_USER=mysql \
	-DMYSQL_TCP_PORT=3306 \
	-DWITH_XTRADB_STORAGE_ENGINE=1 \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_PARTITION_STORAGE_ENGINE=1 \
	-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
	-DWITH_MYISAM_STORAGE_ENGINE=1 \
	-DWITH_READLINE=1 \
	-DENABLED_LOCAL_INFILE=1 \
	-DWITH_EXTRA_CHARSETS=1 \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DEXTRA_CHARSETS=all \
	-DWITH_BIG_TABLES=1 \
	-DWITH_DEBUG=0
	[ $? -ne 0 ]&&exit 1
	make&&make install
	\cp support-files/my-small.cnf  /etc/my.cnf
	\cp support-files/mysql.server /etc/init.d/mysqld
	chmod +x /etc/init.d/mysqld
	chkconfig --add mysqld
	chkconfig mysqld on
	ln -s /usr/local/mysql/bin/* /usr/bin/
	$M_FIX/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data &&>/dev/null
	$M_FIX/bin/mysqld_safe --user=mysql &>/dev/null
	[ `netstat -lnt|grep 3306|wc -l` -ne 0 ]&&echo "MYSQL安装完成.OK"
}
All_1(){
	Http
	Php
}
All_2()
{
	Http
	Php
	Mysql
}
[ $# -eq 0 ]&&exit
[ $1 -eq 1 ]&&Http
[ $1 -eq 2 ]&&Php
[ $1 -eq 3 ]&&Mysql
[ $1 -eq 4 ]&&All_1
[ $1 -eq 5 ]&&All_2
