export HOMEBREW_GITHUB_API_TOKEN=$GH_TOKEN_RW

WDIR="$HOME/code/weaver"
# export DEVSHELL="$WDIR/dev-shell"
# path=($path $DEVSHELL/src/bin .)
# source "$DEVSHELL/src/shell/dev.sh"

kdev() { source ~/bin/$0; }
kuat() { source ~/bin/$0; }
kprod() { source ~/bin/$0; }
wvrlogins() { source ~/bin/$0; }

# for f in kdev kuat kprod wvrlogins; do
#   if ! whence -w $f >/dev/null 2>&1; then
#     autoload -Uz $f
#   fi
# done  

# Set Doppler token if in company directory
# if [[ "$PWD" == "$CODE/$COMPANY"* ]]; then
  export DOPPLER_TOKEN=$(doppler configure get token --plain)
# fi

# source "$DEVSHELL/src/shell/dev.sh"

# source $HOME/code/anshprat/claude-billing/telemetry.sh >/dev/null || true


  export NVM_DIR="$HOME/.nvm"
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"  # This loads nvm
  [ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Dev Shell
export DEVSHELL_DIR="/Users/anshuprateek/code/weaver/devx/dev-shell"
source "$DEVSHELL_DIR/src/shell/dev.sh"

# Prompt Pantry
# export PP_DIR="/Users/anshuprateek/code/weaver/devx/prompt-pantry"
# source "$PP_DIR/shell/rc-init.sh"

alias loom='cd ~/code/weaver/wd/loom'
alias noon=loom
# export CLAUDE_CODE_USE_VERTEX=1
# export CLOUD_ML_REGION=global
# export ANTHROPIC_VERTEX_PROJECT_ID=gen-lang-client-0914416222
export CLAUDE_CODE_NO_FLICKER=1
alias j="just"


# alias justup='tmux -L default kill-server 2>/dev/null; pkill node turbo; just setup && tmux -L default new-session -d -s dev "just backend" \; split-window -h "just frontend" \; attach'
alias justup='tmux -L default kill-server ; pkill -f turbo ; pkill -f node ; just setup ; just build ; just backend ; just frontend'
alias ju=justup

alias build="export GH_TOKEN=$GH_TOKEN_RW && gh workflow run 3a-create-release-tag.yml --repo wvrdz/loom --ref main -f bump-level=patch"

# GitHub MCP plugin (api.githubcopilot.com) reads this var; reuse the RW token
export GITHUB_PERSONAL_ACCESS_TOKEN="$GH_TOKEN_RW"

