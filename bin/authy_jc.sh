#!/bin/zsh

if [ $# -ge 1 ]
then
    arg="cat -"
else
    arg="pbcopy"
fi
source $HOME/.zshrc
$GOPATH/bin/gauth|grep anshu.prateek|awk '{print $3}'| eval ${arg}