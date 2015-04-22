export TERM=xterm
export HISTSIZE=10000
export HISTFILESIZE=100000
alias all='screen -d -r all||screen -S all'
export PATH=$PATH:/usr/local/bin:./
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
alias ssh='ssh -A'
alias p8='ping 8.8.8.8'
