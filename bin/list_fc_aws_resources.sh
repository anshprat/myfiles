#!/bin/bash
today=`date +%F`
for profile in `stsAssumeRole.sh list`
  do
  echo "Processing $profile"
  for region in  `aws ec2 describe-regions --profile $profile --region ap-southeast-1 |grep Name|awk -F '"' '{print $4}'`
    do
    echo "Processing $profile - $region"
    aws ec2 describe-instances --profile ${profile} --region ${region} >> aws_instances_${today}.json
    aws elb describe-load-balancers --profile ${profile} --region ${region} >> aws_elb_${today}.json
  done
done
