consul_token=consul_token_acl
file_name=consul.txt
docker exec -it -e CONSUL_TOKEN=${consul_token} consul consul members -detailed list >${file_name} 
for id in `grep -o id=.................................... ${file_name} |sort|uniq -c|sort -n|grep -ve "^      1"|awk '{print $2}'`; do echo $id ; grep $id ${file_name} ; done
