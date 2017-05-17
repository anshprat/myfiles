sid=$1
r=$2
p=$3

aws ec2 delete-snapshot --snapshot-id ${sid} --region ${r} --profile ${p}  || true