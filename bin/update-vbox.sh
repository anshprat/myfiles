#!/bin/bash
set -x
installed_version=`VBoxManage --version|cut -f 1 -d 'r'`

latest_version=`curl -s http://download.virtualbox.org/virtualbox/LATEST.TXT`

if [ "${installed_version}" != "${latest_version}" ]
then
sudo dnf install -y binutils qt gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms
rpm=`curl -sL http://download.virtualbox.org/virtualbox/${latest_version}|grep 'fedora22-1.x86_64.rpm'|awk -F '"' '{print $2}'`
sudo dnf install -y http://download.virtualbox.org/virtualbox/${latest_version}/${rpm}
fi
sudo /sbin/rcvboxdrv setup
