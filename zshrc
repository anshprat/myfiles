export COMPANY=weaver
export GOPATH=$HOME/code/go
export CODE_PATH="$HOME/code"
export CODE="$HOME/code"
alias c="cd $HOME/code"
alias tfd="cd $HOME/code/$COMPANY/infra/infra-tf"
alias tmp="cd $HOME/tmp"
alias others="cd $HOME/code/others"
alias wd="cd $HOME/code/$COMPANY"
# Set GNU Screen window title to the basename of $PWD
set_screen_title() { printf '\ek%s\e\\' "${PWD:t}"; }
export G="git@github.com:"
# chpwd()  {
#   set_screen_title;
#   if [[ "$PWD" == "$CODE/$COMPANY"* ]]; then
#     export DOPPLER_TOKEN=$(doppler configure get token --plain)
#   fi
# }
# precmd() { set_screen_title; }
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

alias gclogin="gcloud auth login"

export CLAUDE_CODE_CONFIG=/Users/anshuprateek/code/anshprat/claude-billing/claude-code-config.json

alias kustomiz="kustomize"

alias pip="pip3"

alias pt="pwd | pbcopy && open -a Terminal ."

alias pc="pwd | pbcopy"


for git_overload in gco gr gcl; do
#   if ! command -v $git_overload >/dev/null 2>&1; then
    alias $git_overload="cmd=$git_overload $HOME/bin/git.overload.sh"
#   fi
done

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/anshuprateek/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Added by Antigravity
# export PATH="/Users/anshuprateek/.antigravity/antigravity/bin:$PATH"

# Brew upgrade logging - logs all upgrades to ~/tmp/var/log/brew-upgrades.log
source "$HOME/tmp/var/log/brew-upgrade-logger.sh"
alias brew-upgrade='brew_upgrade_logged'

# AI Center - Multi-Agent Communication System
export PATH="${HOME}/.ai-center/bin:${PATH}"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Team AI - Multi-Agent Communication System
export PATH="${HOME}/.team-ai/bin:${PATH}"
