#!/bin/bash
#Find account wise s3 bucket sizes
for p in `stsAssumeRole.sh list`
do
	sleep 1
	echo $p
	aws s3api list-buckets --profile $p; done|tee -a ~/tmp/${p}_s3_buckets_list.txt
	for b in `cat ~/tmp/${p}_s3_buckets_list.txt |grep '"Name"'|awk -F '"' '{print $4}'`
	do 
		sleep 1
		echo ${p}_${b}; 
		bucket_size.sh $b $p 
	done
done