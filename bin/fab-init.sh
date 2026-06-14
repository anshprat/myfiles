cd $PWD
export GH_TOKEN=$GH_TOKEN_RW
git init
curl -fsSL https://raw.githubusercontent.com/wvrdz/fab-kit/main/src/scripts/install.sh | bash
fab/.kit/scripts/fab-sync.sh            # creates directories, symlinks, docs/memory/, .gitignore
mkdir docs/tmp/