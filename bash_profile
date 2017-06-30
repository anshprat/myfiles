# .bash_profile

# Get the aliases and functions
#if [ -f ~/.bashrc ]; then
#	. ~/.bashrc
#fi

# User specific environment and startup programs

PATH=/opt/bin:$HOME/bin:./:$PATH:/usr/local/bin/:/usr/local/go/bin:/usr/local/sbin

export PATH
export TERM=xterm
export HISTSIZE=10000
export HISTFILESIZE=100000
alias all='screen -d -r all||screen -S all'
export PATH=$PATH:/usr/local/bin:./
#export PROMPT_COMMAND='history -a; history -c; history -r; $PROMPT_COMMAND'
#alias ssh='ssh -A'
alias p8='ping 8.8.8.8'
export KEYS=$HOME/code/anshprat/myfiles/private_keys
alias keys='cd $KEYS'
alias tmp="cd $HOME/tmp"
alias sl='ls'
export VAGRANT_DEFAULT_PROVIDER=virtualbox
export GIT="$HOME/code/"
alias sc="cd $GIT/sc"
alias scd="cd $GIT/sc/docker/web.2/scweb"
alias scr="cd $GIT/sc/screact"
#alias /usr/lib64/firefox/plugin-container='optirun /usr/lib64/firefox/plugin-container.orig'
export PS1="\h ${debian_chroot:+($debian_chroot)}:\w\>"
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh
#~/bin/ff-sync
export HISTCONTROL=ignoredups:erasedups 
export PATH="$HOME/.rbenv/bin:$PATH"
