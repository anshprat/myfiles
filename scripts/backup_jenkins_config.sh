#!/bin/bash
#sudo su jenkins
#cd $HOME
IFS='
'
JENKINS_HOME="/app/docker/jenkins/home/"
now=`date +%F-%s`
BACKUP_FOLDER='config_backup_'${now}
cd $JENKINS_HOME
mkdir ${JENKINS_HOME}/${BACKUP_FOLDER}
cd jobs
for config_file in `find .  -name config.xml`
 do
   # dest=`echo $i|sed -e 's/^\.//g'|sed  's/\//|/g'`
   dir=`dirname ${config_file}`
   mkdir -p ../${BACKUP_FOLDER}/${dir}
   #echo "[INFO] copying ${config_file} into ../${BACKUP_FOLDER}/${dir}/"
   cp -rvf ${config_file} ../${BACKUP_FOLDER}/${dir}/

done

cd ..

##
# Assumption for restoring main jenkins config -
# there is no job called 'main_config_*'
##
cp -v $JENKINS_HOME/config.xml $BACKUP_FOLDER/main_jenkins_${now}_config.xml
tar -czvf ${BACKUP_FOLDER}.tgz $BACKUP_FOLDER
echo "backups created in ${BACKUP_FOLDER}.tgz $BACKUP_FOLDER"
