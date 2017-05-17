#!/bin/bash
amid=$1
r=$2
p=$3
set -x
aws ec2 deregister-image --image-id ${amid} --region ${r} --profile ${p} || true