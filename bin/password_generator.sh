#!/bin/bash
pass1=`head /dev/random|md5sum|awk '{print $1}'|tr '[:lower:]' '[:upper:]'|cut -b -15`

r=0
while [ $r -le 15 ]
do 
c=`awk -v min=33 -v max=47 'BEGIN{srand(); printf "%c", int(min+rand()*(max-min+1))}'`
pass2=$pass2$c
sleep 1
let r=r+1
done

pass3=`head /dev/random|md5sum|awk '{print $1}'|cut -b -15`

echo -e "$pass1$pass2$pass3\n"
