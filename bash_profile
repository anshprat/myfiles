# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin:./

export PATH
export TERM=xterm
export HISTSIZE=10000
export HISTFILESIZE=100000
alias all='screen -d -r all||screen -S all'
export PATH=$PATH:/usr/local/bin:./
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
alias ssh='ssh -A'
alias p8='ping 8.8.8.8'
export KEYS=/home/anshup/git/anshprat/myfiles/private_keys
alias admin="source $KEYS/admin_rc"
alias jenkins="source $KEYS/jenkins_oc_rc"
alias devops="source $KEYS/devops_rc"
alias oss="source $KEYS/oss_rc"
alias uc="source $KEYS/undercloud-admin_rc"
