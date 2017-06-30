#!/bin/bash

ROLE_ARN="$1"  
ROLE_SESSION="$2"  
ROLE_JSON="$(aws sts assume-role --role-arn ${ROLE_ARN} --role-session-name ${ROLE_SESSION})"

SECRETKEYREGEX='"SecretAccessKey": "([^"]*)"'  
ACCESSKEYREGEX='"AccessKeyId": "([^"]*)"'  
TOKENREGEX='"SessionToken": "([^"]*)"'

if [[ $ROLE_JSON =~ $SECRETKEYREGEX ]]  
then  
    AWS_SECRET_ACCESS_KEY=${BASH_REMATCH[1]}
    echo "export AWS_SECRET_ACCESS_KEY=${BASH_REMATCH[1]};"
else  
    echo "No secret yo"
    exit 1
fi

if [[ $ROLE_JSON =~ $ACCESSKEYREGEX ]]  
then  
    AWS_ACCESS_KEY_ID=${BASH_REMATCH[1]}
    echo "export AWS_ACCESS_KEY_ID=${BASH_REMATCH[1]};"
else  
    echo "No access key yo"
    exit 1
fi

if [[ $ROLE_JSON =~ $TOKENREGEX ]]  
then  
    AWS_SESSION_TOKEN=${BASH_REMATCH[1]}
    echo "export AWS_SESSION_TOKEN=${BASH_REMATCH[1]};"
else  
    echo "No token yo"
    exit 1
fi

AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \  
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \  
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \  
/bin/bash
