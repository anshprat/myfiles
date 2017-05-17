
for r in `cat ~/bin/aws-regions.txt`
 do echo ${r}
 for p in `cat ~/bin/aws_profiles.txt `
	do echo ${r} ${p} 
	aws ec2 describe-snapshots --region=${r} --profile=${p} --owner-ids self > ~/tmp/s/snapshots_${r}_${p}.json
	grep -E 'SnapshotId|StartTime' ~/tmp/s/snapshots_${r}_${p}.json|grep -E 201[4-6] -A1|grep snap|awk '{print $NF}'|awk -F '"' '{print $2}'|xargs -t -I sid ./snapshot_delete.sh sid ${r} ${p}
#	"aws ec2 delete-snapshot --snapshot-id sid --region ${r} --profile ${p} || true" 
	done
done
