#!/bin/bash
#2018-7-11 15:04:44
#cetnos 7.3
IP=192.168.8.65
yum install git gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl-devel -y 
#libfastcommon
cd libfastcommon/&&./make.sh && ./make.sh install
#fastdfs
cd ..
cd fastdfs&&./make.sh && ./make.sh install
\cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
\cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
\cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
\cp conf/http.conf /etc/fdfs/
\cp conf/mime.types /etc/fdfs/
#fastdfs-nginx-module
cd ..
cp fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs
#nginx install
tar -zxvf nginx-1.12.2.tar.gz
cd nginx-1.12.2/
./configure --add-module=../fastdfs-nginx-module/src/
make && make install

#tracker  config
mkdir -p /fastdfs/tracker
sed -i 's#/home/yuqing/fastdfs#/fastdfs/tracker#g'  /etc/fdfs/tracker.conf
/etc/init.d/fdfs_trackerd restart
chkconfig fdfs_trackerd on
#storage  config
mkdir -p /fastdfs/storage
sed -i 's#/home/yuqing/fastdfs#/fastdfs/storage#g'  /etc/fdfs/storage.conf
sed -i "s#192.168.209.121:22122#$IP:22122#g"  /etc/fdfs/storage.conf
/etc/init.d/fdfs_storaged restart
chkconfig fdfs_storaged on
#client  config
sed -i 's#/home/yuqing/fastdfs#/fastdfs/tracker#g'  /etc/fdfs/client.conf
sed -i "s#192.168.0.197:22122#$IP:22122#g"  /etc/fdfs/client.conf
#mod_fastdfs
sed -i 's#/home/yuqing/fastdfs#/fastdfs/storage#g'  /etc/fdfs/mod_fastdfs.conf
sed -i "s#tracker:22122#$IP:22122#g"  /etc/fdfs/mod_fastdfs.conf
sed -i "s#url_have_group_name = false#url_have_group_name = true#"  /etc/fdfs/mod_fastdfs.conf

cat >/usr/local/nginx/conf/nginx.conf<<EOF
worker_processes  1;
events {
    worker_connections  1024;
}
http {
       include       mime.types;
       default_type  application/octet-stream;
       sendfile        on;
       keepalive_timeout  65;

server {
       listen       8888;
       server_name  localhost;
location ~/group[0-9]/ {
        ngx_fastdfs_module;
        }
  }
server {
        listen       80;
        server_name  localhost;

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
