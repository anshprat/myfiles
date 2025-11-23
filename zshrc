export COMPANY=weaver
export GOPATH=$HOME/code/go
export CODE_PATH="$HOME/code"
export CODE="$HOME/code"
alias c="cd $HOME/code"
alias tfd="cd $HOME/code/$COMPANY/infra-tf"
alias tmp="cd $HOME/tmp"
alias others="cd $HOME/code/others"
alias wd="cd $HOME/code/$COMPANY"
# Set GNU Screen window title to the basename of $PWD
set_screen_title() { printf '\ek%s\e\\' "${PWD:t}"; }
export G="git@github.com:"
chpwd()  { set_screen_title; }
precmd() { set_screen_title; }
#Gcloud bin to path for kubectl etc
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
export SSH_AUTH_SOCK=/Users/anshuprateek/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh


export PATH=$PATH:$HOME/bin:$HOME/.local/bin:$GOPATH/bin:$CODE_PATH/$COMPANY/dev-shell/src/bin
alias s="screen.overload.sh"
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kga="kubectl get all"
alias kctx="kubectl config get-contexts"
alias kuse="kubectl config use-context"
alias d="docker"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dc="docker-compose"
alias bt="byobu-tmux"
alias kustomize="kustomize"

source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

export AWS_PAGER="" 

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

export GH_PAGER=""
