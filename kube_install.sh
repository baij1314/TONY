#!/bin/bash
##  更改主机名  n3
#hostnamectl  set-hostname n3
#timedatectl set-ntp yes
# 环境 ubunet 18.4
#判断是否root用户
if [ "`whoami`" != "root" ];then
    echo "注意：当前系统用户非root用户，将无法执行安装等事宜！" && exit 1
fi

# 全局变量
#k8s docker 镜像地址
images=/data/zxwnfs/kube/kube_image_14.1.tar.gz
#nfs 挂载路径
NfsPath=/data/zxwnfs

function Sysctl_k8s(){ 
    cat <<EOF > /etc/sysctl.d/k8s.conf
et.ipv4.ip_forward = 1
et.bridge.bridge-nf-call-ip6tables = 1
et.bridge.bridge-nf-call-iptables = 1
m.swappiness=0
EOF
    sysctl -p /etc/sysctl.d/k8s.conf &>/dev/null 
}
function Nfs(){
  apt install nfs-common -y && \
  mkdir -p $NfsPath &&  mount -t nfs -o vers=4 10.0.0.28:/ $NfsPath
  if [ $? -eq 0 ] 
  then
    echo  "Mount successfully"
  else
    echo "Mount failed"
  fi
}


function Doker_install(){
    curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg |  apt-key add -  && \
    add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update -y &&  apt  install -y docker-ce=18.06.3~ce~3-0~ubuntu && \
    echo '{"graph": "/data/docker","registry-mirrors": ["https://mirror.ccs.tencentyun.com"]}' > /etc/docker/daemon.json && \
    systemctl start docker && systemctl enable docker  && systemctl restart docker
}

function Doker_image(){
    if [ ! -f $images ];then
    ## pull 
    MyUrl=mirrorgooglecontainers
    images=( kube-apiserver:v1.14.1 kube-controller-manager:v1.14.1 kube-scheduler:v1.14.1 kube-proxy:v1.14.1 pause:3.1  etcd:3.3.10 )
    for imageName in ${images[@]} ; do
      docker pull $MyUrl/$imageName
      docker tag $MyUrl/$imageName k8s.gcr.io/$imageName
      docker rmi $MyUrl/$imageName
    done 
    docker pull coredns/coredns:1.3.1 && \
    docker tag coredns/coredns:1.3.1  k8s.gcr.io/coredns:1.3.1 &&\
    docker rmi coredns/coredns:1.3.1 && \
    docker pull quay.io/coreos/flannel:v0.11.0-amd64  &&  \
    docker pull  quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.0 && \
    docker pull googlecontainer/kubernetes-dashboard-amd64:v1.10.1  && \
    docker tag googlecontainer/kubernetes-dashboard-amd64:v1.10.1 k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1 && \
    docker rmi  googlecontainer/kubernetes-dashboard-amd64:v1.10.1 
    ####  start kubeclet
    systemctl enable docker  
    else
      echo  "导入本地镜像 $images "
      docker load  < $images 
    fi
}

function Kube(){  
    curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
    tee /etc/apt/sources.list.d/kubernetes.list <<-'EOF'
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF
    apt-get update && \
    apt install -y kubeadm=1.14.1-00 kubelet=1.14.1-00   kubectl=1.14.1-00  && \
    systemctl enable kubelet && systemctl start kubelet
    echo " install kubeadm  kubelet kubectl"
    echo "Master  kubeadm init --kubernetes-version=v1.14.1 --pod-network-cidr=10.244.0.0/16"
    echo "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
    echo "Node  kubeadm join  IP :6443  --token ix147b.c0imehcx2cfjb3a7 --discovery-token-ca-cert-hash sha256:f47afcf8b38711122fe9fa7aeb5e19bb2dbb4bc171573a58122f809a0fa09c68 "
}




Menu(){
    echo "当前目录$APP_HOME"
    cat <<EOF
**********运行方式***************
  $0 sysctl   开启网络转换
********************************
  $0 install  安装docker  kubectl
********************************
  $0 kube    安装kubectl 1.14.1
********************************
  $0 image    下载镜像
********************************
  $0 main     运行全部
********************************
EOF
}

function Main(){
    Sysctl_k8s  
    Doker_install   
    Kube    
    Doker_image

}

case $1 in
    sysctl) 
      Sysctl_k8s
    ;;
    nfs) 
      Nfs
    ;;
    install) 
      Doker_install
    ;;
    image) 
      Doker_image
    ;;
    kube)
      Kube
    ;;
    main) 
      Main
    ;;
    *) Menu
    ;;
esac
