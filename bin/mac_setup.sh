#!/bin/bash
set +x
## /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/anshprat/myfiles/master/bin/mac_setup.sh)"

echo "update timestamp_timeout (value is in minutes) using sudo visudo to avoid entering sudo password continuously"

#TODO - check for above value in visudo and proceed accordingly
DEV_NULL=/dev/null

which brew >$DEV_NULL
brew_exists=$?

ok=0
no=1

if [[ $brew_exists == $no ]]
then

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	command='eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile

	cat <(fgrep -i -v "$command" <(cat $HOME/.zprofile)) <(echo "$command") > $HOME/.zprofile

	echo 'in case command line tools fail to install using above or xcode-select --install , then download and install from https://developer.apple.com/download/all/?q=command instead'

fi


mkdir -p ~/tmp/screenshots ~/code/{grab,anshprat,others}

if [ ! -L "$HOME/Desktop/screenshots" ]
then
	ln -sv  ~/tmp/screenshots ~/Desktop/screenshots
fi

echo 'brew installs'

brew_ls=`brew ls`

check_brew_install() {
	pkg=$1
	grep $pkg <<< ${brew_ls} >$DEV_NULL  && echo -e "$pkg \b is already installed"
	pkg_exists=$?
	if [ "${pkg_exists}" == "$no" ]
	then
		export pkgs_to_install="$pkgs_to_install $pkg"
	fi
}

do_brew_install() {
	if [ ! -z "$1" ]
	then
		if [ $(($#-1)) ]
		then
			pkgs_to_install="${@:1:$#-1}"
			cask="${@: -1}"
		else
			pkgs_to_install=$1
		fi

		echo "Installing ${cask} ${pkgs_to_install}"
		brew install $cask $pkgs_to_install
	fi
}

for pkg in curl \
keybase \
postman \
imagemagick \
bitwarden \
1clipboard \
awscli \
jq \
authy \
terminal-notifier \
skitch \
unlox \
whatsapp \
gimp \
dropbox \
microsoft-teams \
adobe-acrobat-reader \
telegram \
signal \
ansible \
qemu \
lima 

do
	check_brew_install $pkg
done

do_brew_install $pkgs_to_install

unset pkgs_to_install


for pkg in firefox \
amazon-chime \
visual-studio-code
do
	check_brew_install $pkg
done

if [ ! -z "$pkgs_to_install" ]
then
	do_brew_install $pkgs_to_install --cask
fi

xcode-select --install 2>$DEV_NULL || echo 'command line tools are already installed, use "Software Update" to install updates'


if [ ! -d /Applications/Bitwarden.app ]
then
	echo "bitwarden application extension needs app store install"
	open "https://apps.apple.com/sg/app/bitwarden/id1352778147?mt=12"
fi

if [ ! -d /Applications/Speedtest.app ]
then
	open "https://apps.apple.com/sg/app/speedtest-by-ookla/id1153157709?mt=12"
fi

mkdir -p ~/code/{grab,anshprat,others}

cd ~/code/anshprat

if [ ! -d dotfiles ]
then
	open /Applications/Keybase.app
	git clone keybase://private/anshu/dotfiles
	cd dotfiles
	cp -rvf .ssh ~/.ssh
	chmod 400 ~/.ssh/*
	cd -
fi

if [ ! -d myfiles ]
then
	git clone https://github.com/anshprat/myfiles.git
	cd myfiles
	git remote remove origin
	git remote add origin git@github.com:anshprat/myfiles.git
	ln -s ~/code/anshprat/myfiles/bin ~/bin
fi

if [ ! -d ~/.oh-my-zsh ]
then
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -f ~/.oh-my-zsh/custom/custom.zsh ] && [ ! -h ~/.oh-my-zsh/custom/custom.zsh ]
then
	CUSTOM_SRC="$HOME/code/anshprat/myfiles/zshrc" 
	CUSTOM_DEST="$HOME/.oh-my-zsh/custom/custom.zsh"
	echo "adding symlink $CUSTOM_SRC to $CUSTOM_DEST"
	ln -s $CUSTOM_SRC $CUSTOM_DEST
fi

command="$HOME/bin/downloads_organizer"
job='3 * * * *  '$command
MAILTO='MAILTO=""'
crontab -l|grep $MAILTO >$DEV_NULL
mailto_exists=$?
crontab -l|grep "[a..z]" >$DEV_NULL
crontab_exists=$?
if [[ $mailto_exists == $no ]]
then
	if [[ $crontab_exists == $no ]]
	then
		cat <(echo "$MAILTO") | crontab -
	else
		cat <(echo "$MAILTO"<(crontab -l)) | crontab -
	fi
fi

crontab -l |grep $command >$DEV_NULL
cron_exists=$?
if [[ $cron_exists == $no ]]
then
	cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
	echo "add cron in preferences -> full disk access"
fi

which virtualenv >$DEV_NULL
venv_exists=$?
if [[ $venv_exists == $no ]]
then
		pip3 install virtualenv
fi

echo "see https://gist.github.com/anshprat/3713bd1bbbf8123e347a8de29a07257e for lima/nerdctl/vde install"