#!/bin/zsh
# set -x
# The below source reduced redundancy at the cost of other redundancies and latency
# source $HOME/.zshrc 
# $GOPATH/bin/gauth|grep anshu.prateek|awk '{print $3}'| eval ${arg}
if [ -z $GOPATH ]
then
    GOPATH=$HOME/code/go/
fi
OP_LOCAL=$($GOPATH/bin/gauth|grep ${USER} -A1)
T_ELAPSED=$(echo ${OP_LOCAL}|grep -o '='|wc -w)


if [ $# -ge 1 ]
then
    arg="cat -"
else
    arg="pbcopy"
fi
let T_REMAIN=30-${T_ELAPSED}
OP=$(echo ${OP_LOCAL}|grep ${USER}|awk '{print $3}'|eval ${arg})
OP_NEXT=$(echo ${OP_LOCAL}|grep ${USER}|awk '{print $4}'|eval ${arg})
echo "${OP}\n${T_REMAIN}\n${OP_NEXT}"

