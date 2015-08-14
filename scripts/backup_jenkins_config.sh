#!/bin/bash
#sudo su jenkins
cd $HOME
now=`date +%F-%s`
backup_folder='config_backup_'${now}
mkdir ${backup_folder}
cd jobs
for i in `find . -maxdepth 2 -name config.xml`
 do 
   dest=`echo $i|sed  's/\//_/g'|sed -e 's/^\._//g'`
   echo $dest
   cp -rvf $i ../${backup_folder}/$dest
done

cd ..

##
# Assumption for restoring main jenkins config -
# there is no job called 'main_config_*'
##
cp -v $HOME/config.xml $backup_folder/main_jenkins_${now}_config.xml
tar -czvf ${backup_folder}.tgz $backup_folder
echo "backups created in ${backup_folder}.tgz $backup_folder"

