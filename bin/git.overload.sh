# git overload
# set -x

args=$@
git_default_server="git@github.com:"

# The aliases are defined as "alias="cmr=$alias $HOME/bin/git.overload.sh"
# so the calling alias sets the cmd variable to the alias name
# for example, alias gco="cmd=gco $HOME/bin/git.overload.sh"
# therefore, cmd variable here captures the original alias used to call this script


# if the command name is gco, then 
# do git checkout main if no args are passed
# else check if $1 starts with $git_default_server, if yes, then pass all args to git checkout

# gcl=git clone
# check if $1 starts with $git_default_server, if yes, then pass all args to git clone
# if $1 does not contain '@' or ':', then add $git_default_server to the beginning of the argument then pass to git clone



case $cmd in
  g)
    if [[ $# -eq 0 ]]; then
      git status
    else
      git "$@"
    fi
    ;;
  gco)
    if [[ $# -eq 0 ]]; then
      git checkout main
    else
      git checkout "$@"
    fi
    ;;
  gcl)
    if [[ $# -eq 0 ]]; then
      echo "Usage: gcl <repository> [git clone options...]"
      exit 1
    fi
    repo="$1"
    shift
    if [[ $repo != *"@"* && $repo != *":"* ]]; then
      git clone "$git_default_server$repo" "$@"
    else
      git clone "$repo" "$@"
    fi
    ;;
  gr)
    # for git remote commands which may contain git server urls, check if the expected arguments contain '@' or ':', if not, add the default git server prefix
    # example: git remote add repo.git => git remote add git@github.com:repo.git
    if [[ $# -eq 0 ]]; then
      git remote -v
    elif [[ $1 == "add" && $3 != *"@"* && $3 != *":"* ]]; then
      git remote add "$2" "$git_default_server$3"
    else
      git remote "$@"
    fi
    ;;
  *)
    echo "Unknown command: $cmd"
    exit 1
    ;;
esac
