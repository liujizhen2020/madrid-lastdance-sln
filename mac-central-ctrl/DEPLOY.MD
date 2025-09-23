部署文档基于 Centos7.x 系统
注意下文中$()中的为变量,用户可以自行定义

1. ==================MongoDB 安装=================
vi /etc/yum.repos.d/mongodb-org-4.0.repo

[mongodb-org]
name=MongoDB Repository
baseurl=http://mirrors.aliyun.com/mongodb/yum/redhat/7Server/mongodb-org/4.0/x86_64/
gpgcheck=0
enabled=1

yum update
yum -y install mongodb-org
systemctl enable mongod.service
systemctl start mongod.service

2. =====================初始化数据=================
2.1 mkdir -p /home/wwwroot/mac-central-ctrl-m/
2.2 将mac-central-ctrl-m.tar.gz 拷贝到 /home/wwwroot/mac-central-ctrl-m/
    tar -zxvf mac-central-ctrl-m.tar.gz
2.3 初始化mongodb
    mongo < /home/wwwroot/mac-central-ctrl-m/db-migrate/mongo.js
    mongo < /home/wwwroot/mac-central-ctrl-m/db-migrate/update.js
2.4 服务配置
    配置/home/wwwroot/mac-central-ctrl-m/conf/app.conf
    
    appname=mac-central-ctrl-m
    bindip=127.0.0.1
    httpport=6060
    ios10gn=xs167
    ios11gn=s167
    clouddomain=127.0.0.1
    ownerid=aaf710ca-eb67-4592-8596-1a848c21023d
    mongourl=127.0.0.1:27017
    mongodb=im
    oplog=off
    dragcert=off
    monitorserver=http://127.0.0.1:7777/sync/data?maintainer=yt167
    runmode=prod


3. ==========部署supervisord守护进程，确保服务可靠性========

3.1 supervisor 安装
yum -y install epel-release 
yum install python-pip 
pip install supervisor
mkdir /etc/supervisor
echo_supervisord_conf > /etc/supervisor/supervisord.conf

3.2 配置supervisor
vi /etc/supervisor/supervisord.conf
添加以下片段

[program:mac-central-ctrl-m]
command=/home/wwwroot/mac-central-ctrl-m/mac-central-ctrl-m     ; the program (relative uses PATH, can take args)
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
directory=/home/wwwroot/mac-central-ctrl-m          ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
;priority=999                  ; the relative start priority (default 999)
autostart=true                 ; start at supervisord start (default: true)
;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
;startretries=3                ; max # of serial start failures when starting (default 3)
autorestart=true               ; when to restart if exited after running (def: unexpected)

3.3 测试
   supervisord -c /etc/supervisor/supervisord.conf
   supervisorctl restart mac-central-ctrl ;使用守护进程启动IMS服务
   
3.4 测试OK配置supervisord 开机启动
   	vi /usr/lib/systemd/system/supervisord.service
  	填入以下内容

# start supervisord.service
# dservice for systemd (CentOS 7.0+) 
# by ET-CS (https://github.com/ET-CS) 
[Unit] 
Description=Supervisor daemon

[Service] 
Type=forking 
ExecStart=/usr/bin/supervisord -c /etc/supervisor/supervisord.conf 
ExecStop=/usr/bin/supervisorctl shutdown 
ExecReload=/usr/bin/supervisorctl reload 
KillMode=process 
Restart=on-failure 
RestartSec=42s

[Install] 
WantedBy=multi-user.target

#end supervisord.service
