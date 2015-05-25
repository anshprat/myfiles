#!/bin/bash
if [ $1 -eq "update" ]
then
sudo apt-get update
fi
if [ ! $2 ]
then 
GIT_HOME=$HOME/git/ril
else
GIT_HOME=$2
fi

sudo apt-get install -y git ruby puppet puppet-common puppet-lint
#sudo gem install librarian-puppet-simple

cd $GIT_HOME
#git clone https://github.com/JioCloud/puppet-rjil.git
cd puppet-rjil
#librarian-puppet install
#ln -s `pwd` modules/rjil
##echo $PWD

