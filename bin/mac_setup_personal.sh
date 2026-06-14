#!/usr/bin/env bash
#
# mac_setup_personal.sh — personal macOS setup that follows me across laptops.
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/anshprat/myfiles/master/bin/mac_setup_personal.sh)"
#
# This is the "who I am on any machine" half of the setup. Work-specific
# tooling (cloud / k8s / IaC + extra runtimes) lives in mac_setup_work.sh,
# and the loom dev loop is provisioned by loom's scripts/setup-dev-env.sh.
#
# Idempotent: safe to re-run. Each step skips work that's already done; a
# failing step is recorded and skipped (summarized at the end, non-zero exit)
# rather than aborting the whole run.

set -uo pipefail

# --- helpers -----------------------------------------------------------------

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }
has()  { command -v "$1" >/dev/null 2>&1; }

FAILED_COUNT=0
FAILED_LIST=""
note_fail() {
  warn "$1 — continuing with the remaining steps."
  FAILED_COUNT=$((FAILED_COUNT + 1))
  FAILED_LIST="${FAILED_LIST}  - $1\n"
}

# Install a formula only if it isn't already present. Tap-qualified names
# (foo/bar/baz) are checked by their final component.
brew_install() {
  local formula="$1"
  brew list "${formula##*/}" >/dev/null 2>&1 || brew install "$formula"
}

# Install a cask only if it isn't already present.
brew_install_cask() {
  local cask="$1"
  brew list --cask "${cask##*/}" >/dev/null 2>&1 || brew install --cask "$cask"
}

# Open the Mac App Store page for an app that brew can't install (e.g. when the
# App Store build is the one we want — Bitwarden's Touch ID Safari extension).
appstore_if_missing() {
  local app="$1" url="$2"
  [[ -d "/Applications/$app" ]] || { warn "$app needs a Mac App Store install"; open "$url"; }
}

# Open an app's official download page when there's no Homebrew cask or App Store
# build for it (manual install required).
download_if_missing() {
  local app="$1" url="$2"
  [[ -d "/Applications/$app" ]] || { warn "$app has no Homebrew cask — opening its download page"; open "$url"; }
}

# --- 1. Homebrew --------------------------------------------------------------

info "Step 1/8: Homebrew"
if ! has brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || die "Homebrew installation failed."
fi
BREW_BIN="/opt/homebrew/bin/brew"
[[ -x "$BREW_BIN" ]] || BREW_BIN="/usr/local/bin/brew"
has brew || eval "$("$BREW_BIN" shellenv)"
grep -qxF "eval \"\$($BREW_BIN shellenv)\"" "$HOME/.zprofile" 2>/dev/null \
  || echo "eval \"\$($BREW_BIN shellenv)\"" >> "$HOME/.zprofile"
has brew || die "Homebrew is not on PATH after install"

# --- 2. Directories + screenshots symlink -------------------------------------

info "Step 2/8: directories + screenshots symlink"
mkdir -p ~/tmp/screenshots ~/code/{grab,anshprat,others}
[[ -L "$HOME/Desktop/screenshots" ]] || ln -sv ~/tmp/screenshots ~/Desktop/screenshots

# --- 3. Taps ------------------------------------------------------------------

info "Step 3/8: taps"
brew tap dopplerhq/cli      >/dev/null 2>&1 || note_fail "tap dopplerhq/cli failed"
brew tap teamookla/speedtest >/dev/null 2>&1 || note_fail "tap teamookla/speedtest failed"

# --- 4. CLI formulae ----------------------------------------------------------

info "Step 4/8: CLI tools"
PERSONAL_FORMULAE=(
  curl wget git
  jq yq ripgrep fzf tree htop
  stow direnv gh pipx
  imagemagick terminal-notifier displayplacer
  doppler                       # secrets manager (all secrets live in Doppler)
  teamookla/speedtest/speedtest
  awscli certbot                # review: move to mac_setup_work.sh if AWS/certs are work-only
)
for pkg in "${PERSONAL_FORMULAE[@]}"; do
  brew_install "$pkg" || note_fail "brew install $pkg failed"
done

# --- 5. GUI apps (casks) ------------------------------------------------------

info "Step 5/8: GUI apps"
PERSONAL_CASKS=(
  google-chrome firefox          # browsers
  1password                      # password manager (Bitwarden via App Store below for Touch ID)
  dropbox telegram whatsapp      # comms / sync
  obsidian notion                # notes
  ghostty                        # terminal
  secretive                      # SSH keys in the Secure Enclave
  shottr                         # screenshots (pairs with ~/Desktop/screenshots)
  caffeine hiddenbar stats rectangle xbar   # menubar / window utilities
  adobe-acrobat-reader gimp postman
  claude-code chatgpt            # AI tools (Claude Code CLI + ChatGPT)
)
for cask in "${PERSONAL_CASKS[@]}"; do
  brew_install_cask "$cask" || note_fail "brew install --cask $cask failed"
done

# Bitwarden: the Mac App Store build carries the Touch ID Safari extension that
# the cask doesn't, so keep installing it from the App Store.
appstore_if_missing "Bitwarden.app" "https://apps.apple.com/sg/app/bitwarden/id1352778147?mt=12"

# No Homebrew cask (or App Store build) exists for these — open the official
# download page if the app isn't already installed.
download_if_missing "Perplexity.app" "https://www.perplexity.ai/"
download_if_missing "Proton Authenticator.app" "https://proton.me/authenticator"

xcode-select --install 2>/dev/null \
  || info 'Command line tools already installed (use "Software Update" for updates).'

# --- 6. dotfiles repo + ~/bin -------------------------------------------------
# NOTE: the old Keybase-based dotfiles/.ssh flow is gone. SSH keys now come from
# Secretive (Secure Enclave) and secrets from Doppler / 1Password / Bitwarden.

info "Step 6/8: myfiles repo + ~/bin symlink"
mkdir -p ~/code/anshprat
if [[ ! -d ~/code/anshprat/myfiles ]]; then
  if git clone https://github.com/anshprat/myfiles.git ~/code/anshprat/myfiles; then
    git -C ~/code/anshprat/myfiles remote set-url origin git@github.com:anshprat/myfiles.git
  else
    note_fail "cloning myfiles failed"
  fi
fi
[[ -L ~/bin ]] || ln -s ~/code/anshprat/myfiles/bin ~/bin

# --- 7. oh-my-zsh + custom.zsh ------------------------------------------------
# powerlevel10k is intentionally NOT installed here. If you keep it, note that
# zshrc sources $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme —
# that line will error until `brew install powerlevel10k` is run by hand.

info "Step 7/8: oh-my-zsh"
[[ -d ~/.oh-my-zsh ]] \
  || sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
  || note_fail "oh-my-zsh install failed"

CUSTOM_DEST="$HOME/.oh-my-zsh/custom/custom.zsh"
if [[ ! -e "$CUSTOM_DEST" ]]; then
  info "linking $CUSTOM_DEST -> myfiles/zshrc"
  ln -s "$HOME/code/anshprat/myfiles/zshrc" "$CUSTOM_DEST"
fi

# --- 8. downloads_organizer cron ----------------------------------------------

info "Step 8/8: downloads_organizer cron"
CRON_CMD="$HOME/bin/downloads_organizer"
CRON_JOB="3 * * * *  $CRON_CMD"
current_cron="$(crontab -l 2>/dev/null || true)"
if ! grep -qF "$CRON_CMD" <<<"$current_cron"; then
  if {
      [[ "$current_cron" == *'MAILTO='* ]] || echo 'MAILTO=""'
      [[ -n "$current_cron" ]] && printf '%s\n' "$current_cron"
      echo "$CRON_JOB"
    } | crontab -; then
    info "Added downloads_organizer cron — grant Full Disk Access to cron in System Settings > Privacy."
  else
    note_fail "installing downloads_organizer cron failed"
  fi
fi

# --- summary ------------------------------------------------------------------

echo
if [[ "$FAILED_COUNT" -gt 0 ]]; then
  warn "Personal setup finished with $FAILED_COUNT issue(s):"
  printf '%b' "$FAILED_LIST" >&2
  warn "The script is idempotent — fix the issues above and re-run it."
else
  info "All personal setup steps completed."
fi
echo "On a work laptop, run bin/mac_setup_work.sh next (and loom's scripts/setup-dev-env.sh for the loom dev loop)."

[[ "$FAILED_COUNT" -eq 0 ]] || exit 1
