#!/bin/bash
log_dir="$HOME/log"
log_file=${log_dir}/`date +%s`.log
sleep_c=10
sudo nc -lk -p 80 > ${log_file} &

last_log_l=0

while [ 1 ]
do
    sleep $sleep_c
    log_l=`wc -l $log_file|awk '{print $1}'`
    if [ $last_log_l -ne $log_l ]
    then
        let new_lines=$log_l-$last_log_l
        tail -n $new_lines $log_file|grep GET|awk '{print $2}'|mail -s "Vrouter alerts" anshprat+vrouteralerts@gmail.com
    fi
    last_log_l=$log_l
done
