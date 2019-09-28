#!/bin/bash
#set -x
# dev prod central
file_dir="/Users/anshup/tmp/"
for account in central
do
    echo $account
    aws ec2 describe-volumes --filters Name=status,Values=available --profile ${account} --query "Volumes[*].{ID:VolumeId}"|grep ID >${file_dir}${account}_ebs.txt
    sleep 1
    sed -i bkp -e 's/"//g' ${file_dir}${account}_ebs.txt
    sleep 1
   for id in `awk '{print $2}' ${file_dir}${account}_ebs.txt` ;
    do  
        echo $id ; 
        aws ec2 delete-volume  --volume-id $id --profile ${account} ; 
        sleep 1
    done
done