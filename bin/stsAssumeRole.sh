#!/bin/bash

LOG_FILE_TO_MONITOR=~/.aws/logs/fc_stsAssumeRole.log
mkdir -p ~/.aws/logs
touch ~/.aws/logs/fc_stsAssumeRole.log
chmod 660 ~/.aws/logs/fc_stsAssumeRole.log

function log(){
    echo -e "--- INFO: $@" >> $LOG_FILE_TO_MONITOR
}

function log_warning(){
    echo -e "=== WARN: $@" >> $LOG_FILE_TO_MONITOR
}

function log_error(){
    echo -e "### ERROR: $@" >> $LOG_FILE_TO_MONITOR
    exit 127
}

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <create/refresh/list> (e.g. \"$0 create\" or \"$0 refresh\" or \"$0 list\")"
    exit 127
fi

if ! which jq 2>&1 > /dev/null ; then
    log_error "$0 error: Please install 'jq'. Try <brew install jq> or <apt-get install jq>"
fi

if ! which aws 2>&1 > /dev/null ; then
    log_error "$0 error: Please install 'awscli'."
fi

if [[ $1 == "list" ]]; then
	cat ~/.aws/config | grep '\[profile ' | cut -d ' ' -f2 | cut -d ']' -f1
	exit 0
fi

USERARN="$(aws --output json iam get-user | jq -r .User.Arn)"

if [[ -z "$USERARN" ]]; then
    log_error "$0 error: unable to determine AWS IAM user. Did you run 'aws configure'?"
fi

IAMUSER="$(basename $USERARN)"

Groups=$(aws --output json iam list-groups-for-user --user-name $IAMUSER)
if [[ -z "$Groups" ]]; then
    log_error "$0 error: unable to determine AWS IAM Groups. You must have AWS iam:GetGroup permission!"
fi

NoOfGroups=$(echo $Groups | jq '.Groups | length')

for i in `seq 0 $NoOfGroups`
do
	GroupsArray[$i]=$(echo $Groups | jq -r .Groups[$i].Arn | cut -d '/' -f2)
done

index=0
for i in ${GroupsArray[@]}; do
	if [ "$i" = "BasePolicies" ] || [ "$i" = "null" ] ; then
        unset GroupsArray[$index]
    fi
    let index++   
done

j=0
log "You are a part of following IAM Groups:"
for i in "${GroupsArray[@]}"
do
	log "$i"
	PoliciesArray[$j]=$(aws --output json iam get-group-policy --group-name $i --policy-name CARole-$i | jq -r .PolicyDocument.Statement[0].Resource)
	let j++
done

for i in "${PoliciesArray[@]}"
do
	profile=`echo $i | cut -d '/' -f2`
	AssumeRoleStatus=$(aws sts assume-role --role-arn $i --role-session-name $profile)
	if [[ $? == 0 ]]
	then
		echo "Profile name  =====> $profile"
		if [[ $1 == "create" ]]
		then
			if ! grep -q $profile ~/.aws/config ; then
				echo "[profile $profile]" >> ~/.aws/config
				echo "role_arn =  $i" >> ~/.aws/config
				echo "source_profile = default" >> ~/.aws/config
			fi
		fi
	else
		log_warning "Unable to assume $i IAM Role"
	fi
done
