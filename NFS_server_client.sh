#!/bin/bash
#2018年1月25日17:13:59
###chenyu

#####################  NFS-SERVER #################
[ $# -eq 0 ]&&echo "Enter $0 1(server)|2(client)"
if[ $1 -eq 1];then
	yum -y install nfs-utils rpc.mountd
	[ ! -d /share/ ]&&mkdir -p /share
	[ `grep 'rw' /etc/exports|wc -l` -eq 0 ]&&{ 
	echo '/share/ 192.168.101.0(rw,insecure,sync,all_squash)' >>/etc/exports
	}
	/etc/init.d/rpcbind start >/dev/null
	/etc/init.d/nfs  start 
fi
##########################   NFS-client
if [ $1 -eq 2 ];then
	yum -y install nfs-utils
	showmount -e
	#mount -t nfs 192.168.101.138:/shared /usr/local/apache2/html
	mount -t nfs 192.168.101.138:/shared /var/www/html
fi
