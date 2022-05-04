#!/bin/bash
set -x
## /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/anshprat/myfiles/master/bin/mac_setup.sh")

echo "update timestamp_timeout (value is in minutes) using sudo visudo first"

which brew
brew_exists=$?

ok=0
no=1

if [[ $brew_exists == $no ]]
then

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	echo 'in case command line tools fail to install using above or xcode-select --install , then download and install from https://developer.apple.com/download/all/?q=command instead'

fi


mkdir -p ~/tmp ~/code/{grab,anshprat,others}

echo 'brew installs'
brew install curl \
keybase \
atom \
postman \
imagemagick \
bitwarden \
1clipboard \
awscli \
jq 

brew install --cask docker

xcode-select --install

echo "bitwarden application extension needs app store install"

mkdir -p ~/code/{grab,anshprat,others}

cd ~/code/anshprat

open /Applications/Keybase.app

cd ~/code/anshprat

if [ ! -d dotfiles ]
then
	git clone keybase://private/anshu/dotfiles
	cd dotfiles
	cp -rvf .ssh ~/.ssh
	cd -
fi

if [ ! -d myfiles ]
then
	git clone git@github.com:anshprat/myfiles.git
	ln -s ~/code/anshprat/myfiles/bin ~/bin
fi

if [ ! -d ~/.oh-my-zsh ]
then
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

grep "PATH" ~/.zshrc|grep "HOME/bin" |grep -v '#'
home_bin_path_exists=$?

if [ "${home_bin_path_exists}" == "$no" ]
then
	echo "Adding \$HOME/bin to \$PATH"
	echo "export PATH=\$HOME/bin:\$PATH">>~/.zshrc
fi


command="/Users/anshup/bin/downloads_organizer"
job='3 * * * *  '$command
crontab -l |grep $command >/dev/null
cron_exists=$?
if [[ $cron_exists == $no ]]
then
	cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
	echo "add cron in preferences -> full disk access"
fi

pip3 install virtualenv
