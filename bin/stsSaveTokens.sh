#!/bin/bash
#This is a recursive file
# The minimum required input is the profile name as setup for octad profile
# After getting the token via oktad this file calls itself with the new tokens
# to save them into the aws credentials file
# The sed here is written for mac sed and will need changes on linux sed

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` profile_name "
  exit 3
fi
profile=${1}

#set -x

creds_file="$HOME/.aws/credentials"

if [ -n "$4" ]
then
  sed_opts="-i .bak -E"
  sed ${sed_opts} '/\['"${profile}"'\]/{N;N;N;d;}' ${creds_file}

  echo "[${profile}]
aws_access_key_id = ${2}
aws_secret_access_key = ${3}
aws_session_token = ${4}" >> ${creds_file}
exit
fi

oktad ${profile} -- /bin/bash -c "`basename $0` ${profile} ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${AWS_SESSION_TOKEN}"
