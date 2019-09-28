#!/usr/bin/env bash

seconds=3600
year=2019
month=09
day=23
#hrs=`range 1 23`
hrs=10
echo "HC=HealthyHosts, RC=RequestCount sum over $((seconds/3600)) hour(s), RPS=RPS per instance"
printf '%-32s %-8s %-15s %-3s\n' "ELB" "HC" "RC" "RPS"
for hr in ${hrs}
do
#

  for elb in `cat elbs.txt`
  do
    metric=Average
    hc=`aws cloudwatch get-metric-statistics \
    --metric-name HealthyHostCount \
    --start-time ${year}-${month}-${day}T${hr}:00:00 \
    --end-time ${year}-${month}-${day}T${hr}:59:00 \
    --period ${seconds} \
    --statistics Average \
    --namespace AWS/ELB \
    --dimensions Name=LoadBalancerName,Value=${elb} \
    --profile prod \
    --region ap-southeast-1|grep ${metric}|cut -f 2 -d ':'|cut -f 1 -d ','|cut -b -5`

    metric=Sum
    rc=`scale=2;aws cloudwatch get-metric-statistics \
    --metric-name RequestCount \
    --start-time ${year}-${month}-${day}T${hr}:00:00 \
    --end-time ${year}-${month}-${day}T${hr}:59:00 \
    --period ${seconds} \
    --statistics Sum \
    --namespace AWS/ELB \
    --dimensions Name=LoadBalancerName,Value=${elb} \
    --profile prod \
    --region ap-southeast-1|grep ${metric}|cut -f 2 -d ':'|cut -f 1 -d ','|bc`



    #echo "For ${elb} RequestCount is ${rc}, HealthyHostCount is ${hc} "
    if [[ ! -z $rc ]]
    then
        rps=`echo "scale=2;${rc}/(${hc}*${seconds})"|bc`
        printf '%-32s %-8s %-15s %-3s\n' ${elb} ${hc} ${rc} ${rps}
    fi
  done
done
