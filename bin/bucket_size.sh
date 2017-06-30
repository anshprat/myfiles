#!/bin/bash
bucket=$1
profile=$2
now=$(date +%s)
aws cloudwatch get-metric-statistics --namespace AWS/S3 --start-time "$(echo "$now - 86400" | bc)" --end-time "$now" --period 86400 --statistics Average --region us-east-1 --metric-name BucketSizeBytes --dimensions Name=BucketName,Value="$bucket" Name=StorageType,Value=StandardStorage  \
--profile ${profile}