# .bash_profile

# Get the aliases and functions
#if [ -f ~/.bashrc ]; then
#	. ~/.bashrc
#fi

# User specific environment and startup programs

PATH=$HOME/bin:./:$PATH

export PATH
export TERM=xterm
export HISTSIZE=10000
export HISTFILESIZE=100000
alias all='screen -d -r all||screen -S all'
export PATH=$PATH:/usr/local/bin:./
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
#alias ssh='ssh -A'
alias p8='ping 8.8.8.8'
export KEYS=/home/anshup/git/anshprat/myfiles/private_keys
alias keys='cd $KEYS'
alias tmp="cd $HOME/tmp"
alias sl='ls'
export VAGRANT_DEFAULT_PROVIDER=virtualbox
export GIT="$HOME/git/"
alias sc="cd $GIT/sc"
#alias /usr/lib64/firefox/plugin-container='optirun /usr/lib64/firefox/plugin-container.orig'
