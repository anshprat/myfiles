#!/bin/bash
#set -xe
#sudo su jenkins
backup_archive=$1
cd $HOME
if ! [ -e jobs ]
  then
    echo '[WARN]jobs folder does not exist. Is it a valid jenkinst installation?'
    echo '[CRITICAL] [ERROR] Exitiing!!'
    exit 13
fi

if ! [ -e "$backup_archive" ] && ! [ -n "$backup_archive" ]
  then
    echo "[CRITICAL] Given archive $backup_archive not found. Please check"
    echo '[CRITICAL] [ERROR] Exitiing!!'
    exit 14
fi

##
# Not checking if the given archive is a valid tar or not
# Assuming its been given a valid tar archive as generated
# by backup script
##

tmp_folder="/tmp/restore_jenkins_`date +%F-%s`"
mkdir -v $tmp_folder
cp -v $backup_archive $tmp_folder
tar -C $tmp_folder -xzvf $tmp_folder/$backup_archive

cd $HOME/jobs

for i in `ls ${tmp_folder}/*/*_config.xml`
  do 
  job_tmp=`echo $i|rev|cut -f 2- -d '_'|rev`
  job=`basename $job_tmp`
  mkdir -v $job
  cp -v $i $job/config.xml
done
##
# Assumption for restoring main jenkins config -
# there is no job called 'main_config_*'
##
mv -v main_jenkins_*/config.xml $HOME/config.xml
rm -rvf main_jenkins_*

rm -rf $tmp_folder
