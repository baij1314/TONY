#!/bin/bash
#cetnos 6.8
#FastDFS_v5.08

IP=192.168.1.113
yum -y install  gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl-devel

LIB(){
	unzip libfastcommon-master.zip && cd libfastcommon-master && ./make.sh && ./make.sh install 
	echo "install libfastcommon OK "
}
FASTDFS(){
	tar xf FastDFS_v5.08.tar.gz && cd FastDFS  && ./make.sh && ./make.sh install 
	\cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
	\cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
	\cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
	\cp conf/http.conf /etc/fdfs/
	\cp conf/mime.types /etc/fdfs/
}
NG_FDFS(){
	tar xf fastdfs-nginx-module_v1.16.tar.gz &&tar xf  ngx_cache_purge-2.3.tar.gz &&cp fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs
	sed -i 's#usr/local/include#usr/include#g'   fastdfs-nginx-module/src/config
}
FDFS_C(){
	mkdir -p /fastdfs/tracker&& mkdir -p /fastdfs/storage 
	#storage
	sed -i 's#/home/yuqing/fastdfs#/fastdfs/tracker#g'  /etc/fdfs/tracker.conf
	sed -i 's#/home/yuqing/fastdfs#/fastdfs/storage#g'  /etc/fdfs/storage.conf
	sed -i "s#192.168.209.121:22122#$IP:22122#g"  /etc/fdfs/storage.conf
	#client
	sed -i 's#/home/yuqing/fastdfs#/fastdfs/tracker#g'  /etc/fdfs/client.conf
	sed -i "s#192.168.0.197:22122#$IP:22122#g"  /etc/fdfs/client.conf
	#mod_fastdfs.conf
	sed -i 's#/home/yuqing/fastdfs#/fastdfs/storage#g'  /etc/fdfs/mod_fastdfs.conf
	sed -i "s#tracker:22122#$IP:22122#g"  /etc/fdfs/mod_fastdfs.conf
	sed -i "s#url_have_group_name = false#url_have_group_name = true#"  /etc/fdfs/mod_fastdfs.conf
	#chkconfig
	/etc/init.d/fdfs_trackerd restart
	chkconfig fdfs_trackerd on
	/etc/init.d/fdfs_storaged restart
	chkconfig fdfs_storaged on
}
NGINX(){
	tar xf nginx-1.10.0.tar.gz&& cd nginx-1.10.0 
	./configure --add-module=../fastdfs-nginx-module/src/ --add-module=../ngx_cache_purge-2.3
	make && make install
}
NG_C(){
	cat >/usr/local/nginx/conf/nginx.conf<<EOF
	worker_processes  1;
	events {
	    worker_connections  1024;
	}
	http {
	       include       mime.types;
	       default_type  application/octet-stream;
	       sendfile        on;
	       keepalive_timeout  65	
	server {
	       listen       8888;
	       server_name  localhost;
	location ~/group[0-9]/ {
	        ngx_fastdfs_module;
	        }
	  }
	server {
	        listen       80;
	        server_name  localhost	
	location / {
	            root   html;
	            index  index.html index.htm;
	        }
	location /group1/M00 {
	        proxy_next_upstream http_502 http_504 error timeout invalid_header;
	        proxy_pass http://localhost:8888;
	        expires 30d;
	        }
	  }
	}
EOF
/usr/local/nginx/sbin/nginx -t
}




LIB&& FASTDFS&& NG_FDFS&& FDFS_C&& NGINX


