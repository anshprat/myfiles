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

  # ~/.zshrc prepends ~/.local/bin (hermes Node 26) after this file loads, and
  # `nvm use` swaps the version in place, so hermes Node still wins. Move the
  # selected Node to the front of PATH after every `nvm use` / `nvm install`.
  if (( $+functions[nvm] )); then
    functions[_nvm_orig]=$functions[nvm]
    nvm() {
      _nvm_orig "$@" || return
      [[ $1 == (use|install) && -n $NVM_BIN ]] && path=("$NVM_BIN" ${path:#$NVM_BIN})
    }
  fi

# Dev Shell
#export DEVSHELL_DIR="/Users/anshuprateek/code/weaver/devx/dev-shell"
#source "$DEVSHELL_DIR/src/shell/dev.sh"

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
alias justup='tmux -L default kill-server ; pkill -f turbo ; pkill -f node ; just setup ; just build ; just backend ; just web'
alias ju=justup

# Trigger loom's "3a. Create Release Tag" workflow (version bump + git tag).
# https://github.com/wvrdz/loom/actions/workflows/3a-create-release-tag.yml
#
#   loom-release                      # patch bump on main
#   loom-release minor                # minor bump on main
#   loom-release patch my-branch      # bump on a custom branch (pushes tags only)
#   loom-release -s none my-branch    # ... and skip 3d's #bot-releases post
#   loom-release -s '#my-chan' my-branch  # ... and send 3d's post to #my-chan instead
#   loom-release -w                   # dispatch, then stream the run
#   loom-release -n minor             # print the gh command, dispatch nothing
#
# --slack / -s sets 3a's optional `slack-channel` input, which 3a passes to 3d:
#   (blank) | default   -> #bot-releases (vars.SLACK_CHANNEL_BOT_RELEASES)
#   none               -> no release post
#   C… ID | #name      -> that channel (a private one needs @Ping invited)
# -q / --quiet is shorthand for --slack none.
#
# 3a only chains into 3b (docker) / 3c (DMG) / 3d (signed DMG) when dispatched
# from a branch ref.
loom-release() {
  local bump=patch branch=main slack='' watch=0 dry=0

  while (( $# )); do
    case "$1" in
      patch|minor|major) bump="$1" ;;
      -s|--slack)
        if [[ -z "$2" ]]; then
          print -u2 "loom-release: $1 needs a channel (none|default|C…|#name)"; return 1
        fi
        slack="$2"; shift ;;
      --slack=*)         slack="${1#--slack=}" ;;
      -q|--quiet)        slack=none ;;
      -w|--watch)        watch=1 ;;
      -n|--dry-run)      dry=1 ;;
      -h|--help)
        print -- 'usage: loom-release [patch|minor|major] [branch] [-s|--slack none|default|C…|#name] [-q|--quiet] [-w|--watch] [-n|--dry-run]'
        return 0 ;;
      -*)
        print -u2 "loom-release: unknown flag '$1' (try --help)"; return 1 ;;
      *)                 branch="$1" ;;
    esac
    shift
  done

  local repo=wvrdz/loom wf=3a-create-release-tag.yml
  # Scope the RW token to this function only; fall back to gh's own auth.
  [[ -n "$GH_TOKEN_RW" ]] && local -x GH_TOKEN="$GH_TOKEN_RW"

  # Only send slack-channel when set — blank is 3a's own default.
  local -a run_args=(-f "bump-level=$bump")
  [[ -n "$slack" ]] && run_args+=(-f "slack-channel=$slack")

  if (( dry )); then
    print -r -- "gh workflow run $wf --repo $repo --ref $branch ${(q-)run_args[@]}"
    return 0
  fi

  print -- "==> 3a. Create Release Tag  repo=$repo  ref=$branch  bump=$bump  slack=${slack:-default}"

  # Remember the newest dispatch run so we can tell ours apart from it.
  local -a list_args=(--repo "$repo" --workflow "$wf" --branch "$branch"
                      --event workflow_dispatch --limit 1
                      --json databaseId --jq '.[0].databaseId // ""')
  local before after
  before=$(gh run list $list_args)

  gh workflow run "$wf" --repo "$repo" --ref "$branch" "${run_args[@]}" || return

  local i
  for i in {1..10}; do
    sleep 2
    after=$(gh run list $list_args)
    [[ -n "$after" && "$after" != "$before" ]] && break
  done

  if [[ -z "$after" || "$after" == "$before" ]]; then
    print -u2 "loom-release: dispatched, but the run hasn't shown up yet — check:"
    print -u2 "  https://github.com/$repo/actions/workflows/$wf"
    return 0
  fi

  print -- "==> https://github.com/$repo/actions/runs/$after"
  (( watch )) && gh run watch "$after" --repo "$repo" --exit-status
}

alias build='loom-release'
alias dmg=build

# GitHub MCP plugin (api.githubcopilot.com) reads this var; reuse the RW token
export GITHUB_PERSONAL_ACCESS_TOKEN="$GH_TOKEN_RW"

eval "$(direnv hook zsh)"

eval "$(wt shell-init zsh)"