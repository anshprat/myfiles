for i in `awk -F '|' '{print $3}' ironic-nova-list|grep $1 `
do 
	echo $i
	id=`grep $i ironic-nova-list|awk -F '|' '{print $2}'`
	echo $id
	if [ ! -z $id ]
	then  
		grep $id iloip -B1
	fi
done 

