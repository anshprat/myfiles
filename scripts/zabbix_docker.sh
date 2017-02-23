#!/bin/bash
#set -x
zabbix_mysql_data=$HOME/docker_root/var/lib/mysql
mkdir -p $zabbix_mysql_data

docker run -h zabbix-mysql -p 8080:8080 --name zabbix-mysql -v $zabbix_mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mysql -d mysql:8.0


#Passive check agent
docker run -h zabbix-agent-passive -p 8081:8080 --name zabbix-agent-passive -e ZBX_HOSTNAME="zabbix-agent-passive"  -d zabbix/zabbix-agent

#Main server with link to above agent for passive check
docker run -h zabbix-server  -p 8085:8080 --link zabbix-mysql:zabbix-mysql-server  --link zabbix-agent-passive:zabbix-agent --name zabbix-server -e DB_SERVER_HOST="zabbix-mysql-server" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="zabbixpassword" -d -p 10051:10051 -p 162:162/udp zabbix/zabbix-server-mysql:latest


#Active check agent

docker run -h zabbix-agent-active -p 8083:8080 --name zabbix-agent-active --link zabbix-server:zabbix-server -d zabbix/zabbix-agent:latest


# Zabbix Web UI
docker run -h zabbix-ui -p 8084:8080 --name zabbix-web-nginx-mysql  --link zabbix-server:zabbix-server --link zabbix-mysql:zabbix-mysql-server -e DB_SERVER_HOST="zabbix-mysql-server" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="zabbixpassword" -e ZBX_SERVER_HOST="zabbix-server" -e TZ="UTC" -d -p 8082:80 zabbix/zabbix-web-nginx-mysql

zserver_ip=`docker inspect zabbix-server|grep IPAddress|tail -n 1|awk -F '"' '{print $4}'`

docker exec -it  zabbix-agent-passive bash -c "echo ${zserver_ip} zabbix-server|tee -a /etc/hosts"


echo "waiting for mysql to comeup and then add creds"

sleep_wait=60
for i in `seq 1 ${sleep_wait}`; do printf '\b%.0s' {1..60};echo -ne  "waiting for $((60-$i)) sec"; sleep 1; 

  docker exec -it zabbix-mysql mysql -u root -pmysql -e 'use mysql;grant all on *.* to zabbix identified by "zabbixpassword"; flush privileges;' 
  if [ $? -eq 0 ]
  then
    sleep 5
    open http://127.0.0.1:8082/
    exit 0
  fi

done


