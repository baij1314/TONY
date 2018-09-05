#!/bin/bash
#uwen mpurse
#2018-08-24
#baij1314@163.com
USER=admin
PWD=admin
WARDIR=/root/war
PORT=$1
WARLS="cc.war kms.war message.war acc.war op.war member.war trisk.war workflow.war querycenter.war api.war website.war oms.war"
##  curl -u admin:admin  "http://localhost:8080/manager/text/deploy?path=/cc&war=file:/root/war/cc.war"

Findleaks(){
	#查看 内存泄漏
    curl -u $USER:$PWD "http://localhost:$PORT/manager/text/findleaks"
}
CACHES(){
	#  清缓存内存
    echo 1 > /proc/sys/vm/drop_caches
    echo 2 > /proc/sys/vm/drop_caches
    echo 3 > /proc/sys/vm/drop_caches
}

LIST(){
	#查看 war 列表
    curl -u $USER:$PWD  http://localhost:$PORT/manager/text/list
}

UNDEPLOY(){
	#卸载 war 包
	for n in $WARLS;
    do                  
        i=`echo $n|sed 's/.war//g'`
        curl -u $USER:$PWD  "http://localhost:$PORT/manager/text/undeploy?path=/$i"
    done
}

DEPLOY(){
	#部署 war 包
    for n in $WARLS;
    do
        i=`echo $n|sed 's/.war//g'`
        curl -u $USER:$PWD  "http://localhost:$PORT/manager/text/deploy?path=/$i&war=file:${WARDIR}/$n"
    done
}
START(){
	#启动全部war 包
    for n in $WARLS;
    do
      i=`echo $n|sed 's/.war//g'`
      curl -u  $USER:$PWD  "http://localhost:$PORT/manager/text/start?path=/$i"
    done
}
STOP(){
	#停止全部war 包
    for n in $WARLS;
    do
      i=`echo $n|sed 's/.war//g'`
      curl -u  $USER:$PWD  "http://localhost:$PORT/manager/text/stop?path=/$i"
    done
}

case "$2" in
    deploy)
        DEPLOY
        ;;
    undeploy)
        UNDEPLOY
        $1
        ;;
    list)
        LIST
        ;;
    start)
        START
        ;;
    status)
        Findleaks
        ;;
    all|ALL)
        UNDEPLOY
		DEPLOY
		LIST
		;;
	stop)
        STOP
        ;;
    caches)
    	CACHES
    	;;
    findleaks)
    	Findleaks
    	;;
    *)
        echo $"Usage: $0 8080 {start|stop|status|deploy|undeploy|caches|list|all|findleaks}"
        exit 2
esac
