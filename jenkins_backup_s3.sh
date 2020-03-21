#!/bin/bash
date=`date +%Y/%m/%d`
JENKINS_HOME="/app/docker/jenkins/home/"
now=`date +%F-%s`
BACKUP_FOLDER='config_backup_'${now}
S3_BUCKET=grabpay-backup
S3_PATH="central/sysops/jenkins"
IFS='
'
cd $JENKINS_HOME
mkdir ${JENKINS_HOME}/${BACKUP_FOLDER}
cd jobs
for config_file in `find .  -name config.xml`
 do
   dir=`dirname ${config_file}`
   mkdir -p ../${BACKUP_FOLDER}/${dir}
   cp -rvf ${config_file} ../${BACKUP_FOLDER}/${dir}/

done

cd ..

##
# Assumption for restoring main jenkins config -
# there is no job called 'main_config_*'
##
cp -v $JENKINS_HOME/config.xml $BACKUP_FOLDER/main_jenkins_${now}_config.xml
tar -czvf ${BACKUP_FOLDER}.tgz $BACKUP_FOLDER

/usr/bin/aws s3 cp ${JENKINS_HOME}/${BACKUP_FOLDER}.tgz s3://${S3_BUCKET}/${S3_PATH}/${date}/${BACKUP_FOLDER}.tgz

#/usr/bin/aws s3 sync /app/docker/jenkins/home s3://grabpay-backup/central/sysops/jenkins/home
