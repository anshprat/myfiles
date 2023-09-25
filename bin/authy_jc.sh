#!/bin/bash

if [ $# -ge 1 ]
then
    arg="cat -"
else
    arg="pbcopy"
fi

$GOPATH/bin/gauth|grep jumpcloud|awk '{print $3}'| $arg