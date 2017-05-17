p=1
next="https://api.bitbucket.org/2.0/repositories/freecharge?page=$p"
while [ $p -gt 0 ]
do
curl --basic --user anshuprateek:apipassword "${next}" >p${p}.json
next=`cat p${p}.json|tr ',' '\n' |grep next|awk -F '"' '{print $4}'`
let p=p+1
n=`echo $next|wc -c`
if [ $n -lt 60 ]
then
p=0
fi
done
cat p*.json |tr ',' '\n'|grep clone|cut -f 2 -d '@'|awk -F '"' '{print $1}' > repos.txt
