#!/bin/bash
#Spacewalk install as per https://github.com/spacewalkproject/spacewalk/wiki/HowToInstall

#Verify that the Satellite's /etc/hosts file contains correct entries for the localhost and fully-qualified domain name (e.g., 'satellite.example.com'):
#'

rpm -Uvh http://yum.spacewalkproject.org/2.6/RHEL/7/x86_64/spacewalk-repo-2.6-0.el7.noarch.rpm

cat > /etc/yum.repos.d/jpackage-generic.repo << EOF
[jpackage-generic]
name=JPackage generic
baseurl=http://mirrors.dotsrc.org/pub/jpackage/5.0/generic/free/
#mirrorlist=http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=5.0
enabled=1
gpgcheck=1
gpgkey=http://www.jpackage.org/jpackage.asc
EOF

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum -y install spacewalk-setup-postgresql

yum -y install spacewalk-postgresql 

spacewalk-setup  --skip-db-install

sudo yum downgrade c3p0.noarch 0:0.9.1.2-2.jpp5