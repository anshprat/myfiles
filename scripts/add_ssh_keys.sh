#!/bin/bash
mkdir ~/.ssh
AUTH_KEYS_FILE=~/.ssh/authorized_keys
curl -o ${AUTH_KEYS_FILE} https://github.com/anshprat.keys
chmod 500 ${AUTH_KEYS_FILE}
