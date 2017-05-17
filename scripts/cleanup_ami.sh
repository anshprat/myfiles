FS="~/tmp"

for r in `cat ~/bin/aws-regions.txt`
 do echo ${r}
 for p in `cat ~/bin/aws_profiles.txt `
	do echo ${r} ${p} 
		aws ec2 describe-images --region=${r} --profile=${p} --owners self > ~/tmp/images_${r}_${p}.json
		grep -E 'ImageId|CreationDate' ~/tmp/images_${r}_${p}.json |grep 201[3-6] -B1|grep Image|awk -F '"' '{print $4}' |xargs -t -I amid ./delete_ami.sh amid  ${r}  ${p}
#aws ec2 deregister-image --image-id amid --region ${r} --profile ${p}		
	done
done
