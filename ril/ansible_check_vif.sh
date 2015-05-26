#!/bin/bash
log_dir="$HOME/log"
log_file=${log_dir}/`date +%F`.log
sleep_time_c=10
sleep_time=${sleep_time_c}

while [ 1 ]
do
    sleep ${sleep_time}
    nodes_b=`ansible vrouters -m shell -a 'curl -s -m 5 -o /dev/null http://localhost:8085/Snh_ItfReq?name= ; echo $?'|grep 28 -B 1 |grep cp|awk '{print $1}'`

    if [ ! -z $nodes_b ]
    then
        nodes=`echo $nodes_b|tr ' ' '&'`
        echo "[ERROR] `date` `date +%s` failures for ${nodes}" >>$log_file
        curl -o /dev/null -m 2 -x http://10.135.121.138:3128 http://49.40.64.225/nodes=$nodes
        let sleep_time=sleep_time*2
     else
        sleep_time=${sleep_time_c}
     fi

done