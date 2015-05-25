#!/bin/bash


contrail_logs=('contrail-api'
		'contrail-schema'
		'contrail-vrouter-agent'
		'contrail-discovery'
		'vnc_openstack.err'
		'svc-monitor.err'
		'schema.err'
		'api-0-zk'
		'schema-zk'
		)

log_dir='/var/log/contrail/'
for log in ${contrail_logs[@]} 
do 
file="${log_dir}${log}"
file_log="${file}.log.1"
file_daily="${file}-daily.log"


case $log in
	err)
		echo "this is err"
	;;
esac

done
