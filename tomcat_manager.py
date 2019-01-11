#!/usr/bin/python3
import requests
import os
import sys

class Tomcat:

    def __init__(self, host, port, user, passwd, list_war, prefix):
        self.host = host
        self.port = port
        self.auth = (user, passwd)
        self.list_war = list_war
        self.prefix = prefix
        self.array = []
        self.suffix = []

    ###  排列 war 包
    @property
    def array_war(self):
        array = self.array
        prefix = os.listdir(self.prefix)
        for row in self.list_war:
            if row in prefix:
                array.append(prefix.pop(prefix.index(row)))
        return array

    ##  去后 war 缀名
    @property
    def suffixs(self):
        suffix = self.suffix
        for row in self.array:
            if row.endswith('.war'):
                suffix.append(row.split('.')[0])
        return suffix

    ##  获取 tomcat列表内容
    @property
    def lists(self):
        url = 'http://{}:{}/manager/text/list'.format(self.host, self.port)
        req = requests.get(url, auth=self.auth)
        strs = req.text.splitlines()
        list_dir = []
        for i in strs:
            if i.startswith('/'):
                if not i.startswith('/manager'):
                    list_dir.append(i.split(':')[0])
        return list_dir

    # 调用tomcat 列表的内容 卸载war包
    @property
    def undeploy(self):
        for i in self.lists:
            url = 'http://{}:{}/manager/text/undeploy?path={}'.format(self.host, self.port, i)
            req = requests.get(url, auth=self.auth).text
            return ret

    # 调用tomcat 列表的内容 停止war包
    @property
    def stop(self):
        for i in self.lists:
            url = 'http://{}:{}/manager/text/stop?path={}'.format(self.host, self.port, i)
            req = requests.get(url, auth=self.auth).text
            print(req, end='')

    # 调用导入 列表的内容 开始war包
    @property
    def start(self):
        for i in self.list_war:
            url = 'http://{}:{}/manager/text/start?path=/{}'.format(self.host, self.port, i)
            req = requests.get(url, auth=self.auth).text
            print(req, end='')

    @property
    def deploy(self):
        self.array_war
        for n in self.suffixs:
            url = 'http://{}:{}/manager/text/deploy?path=/{}&war=file:{}'.format(self.host, self.port, n, n + '.war')
            req = requests.get(url, auth=self.auth).text
            print(req, end='')

    @property
    def updeploy(self):
        self.array_war
        for i in self.suffixs:
            url = 'http://{}:{}/manager/text/deploy?path=/{}'.format(self.host, self.port, i)
            data = open(self.prefix + i + '.war', 'rb').read()
            req = requests.put(url, data, auth=self.auth).text
            print(req, end='')


if __name__ == "__main__":
    # 包的顺序
    war = ['cc.war', 'kms.war', 'message.war', 'account.war', 'op.war', 'member.war', 'trisk.war',
           'trade.war', 'workflow.war', 'qcenter.war', 'api.war', 'website.war', 'oms.war', 'war']
    # war路径
    prefix = '/home/uwen/go/'

    ret = Tomcat("192.168.8.65", 8080, 'admin', 'admin', war, prefix)
    # 命令
    if len(sys.argv) < 2:
        print(''' 1|start 2|stop 3|deploy 4|undeploy 5|updeploy''')
        sys.exit()
    if sys.argv[1] == 'start':
        ret.start
    elif sys.argv[1] == 'stop':
        ret.stop
    elif sys.argv[1] == 'lists':
        ret.lists
    elif sys.argv[1] == 'deploy':
        ret.deploy
    elif sys.argv[1] == 'updeploy':
        ret.updeploy
    elif sys.argv[1] == 'undeploy':
        ret.undeploy
    else:
        print('你输入有误，请重新输入！')
        sys.exit()
