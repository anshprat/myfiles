#!/usr/bin/env bash
#
# mac_setup_work.sh — work-laptop-only tooling (cloud / k8s / IaC + runtimes).
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/anshprat/myfiles/master/bin/mac_setup_work.sh)"
#
# Division of responsibility:
#   - mac_setup_personal.sh ............ identity + apps for every laptop
#   - loom scripts/setup-dev-env.sh .... the loom dev loop (Homebrew, pnpm/just/
#                                        git/direnv/tmux/yq/jq, Node 24.15 via
#                                        nvm, pm2, shll/fab, Docker, ghcr auth,
#                                        clone loom) — run that for loom work
#   - THIS script ...................... the cloud/k8s/IaC stack + extra runtimes
#                                        that loom's onboarding leaves out
#
# Run mac_setup_personal.sh first (it bootstraps Homebrew). Idempotent: safe to
# re-run; failing steps are recorded and skipped, then summarized at the end.

set -uo pipefail

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

brew_install() {
  local formula="$1"
  brew list "${formula##*/}" >/dev/null 2>&1 || brew install "$formula"
}
brew_install_cask() {
  local cask="$1"
  brew list --cask "${cask##*/}" >/dev/null 2>&1 || brew install --cask "$cask"
}

has brew || die "Homebrew not found. Run mac_setup_personal.sh first."

# --- 1. Taps ------------------------------------------------------------------

info "Step 1/5: taps"
brew tap hashicorp/tap >/dev/null 2>&1 || note_fail "tap hashicorp/tap failed"

# --- 2. Language runtimes -----------------------------------------------------
# Node comes from loom's setup-dev-env.sh (pinned to 24.15 via nvm); nvm is
# installed here too so it exists even if you skip the loom script. pnpm is also
# installed by the loom script — kept here so a standalone work laptop has it.

info "Step 2/5: language runtimes"
WORK_RUNTIMES=(
  nvm pnpm yarn
  uv                # modern Python package/venv manager (replaces pipx+virtualenv)
  go
  python@3.13
)
for pkg in "${WORK_RUNTIMES[@]}"; do
  brew_install "$pkg" || note_fail "brew install $pkg failed"
done

# Node via nvm, pinned to match loom's setup-dev-env.sh. Skip with NODE_VERSION=skip.
NODE_VERSION="${NODE_VERSION:-24.15}"
if [[ "$NODE_VERSION" != "skip" ]]; then
  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"
  NVM_SH="$(brew --prefix nvm 2>/dev/null)/nvm.sh"
  if [[ -s "$NVM_SH" ]]; then
    set +u
    # shellcheck disable=SC1090
    . "$NVM_SH"
    if nvm install "$NODE_VERSION" && nvm alias default "$NODE_VERSION"; then
      info "node $(node --version)"
    else
      note_fail "Node $NODE_VERSION install via nvm failed"
    fi
    set -u
  else
    note_fail "nvm.sh not found under $(brew --prefix nvm 2>/dev/null); skipped Node"
  fi
fi

# --- 3. Kubernetes / cloud CLIs -----------------------------------------------
# NOTE: gcloud-cli (next step) also ships a kubectl under its SDK bin dir. If you
# install kubernetes-cli here too, make sure PATH ordering picks the one you want.

info "Step 3/5: kubernetes tooling"
WORK_K8S=(
  kubernetes-cli   # kubectl (gcloud SDK also provides one — see note above)
  helm
  kustomize
  argocd
  cmctl
  k9s
)
for pkg in "${WORK_K8S[@]}"; do
  brew_install "$pkg" || note_fail "brew install $pkg failed"
done

# --- 4. Infrastructure as code ------------------------------------------------

info "Step 4/5: infrastructure as code"
WORK_IAC=(
  hashicorp/tap/terraform
  hashicorp/tap/packer
)
for pkg in "${WORK_IAC[@]}"; do
  brew_install "$pkg" || note_fail "brew install $pkg failed"
done

# --- 5. Work casks ------------------------------------------------------------

info "Step 5/5: work GUI apps"
WORK_CASKS=(
  gcloud-cli      # Google Cloud SDK (provides gcloud + a kubectl)
  lens            # Kubernetes IDE
  1password       # password manager + Safari extension (work vault)
  granola         # meeting notes
  linear          # issue tracking
  microsoft-teams # work comms
  tailscale       # VPN / mesh networking
)
for cask in "${WORK_CASKS[@]}"; do
  brew_install_cask "$cask" || note_fail "brew install --cask $cask failed"
done

# --- summary ------------------------------------------------------------------

echo
if [[ "$FAILED_COUNT" -gt 0 ]]; then
  warn "Work setup finished with $FAILED_COUNT issue(s):"
  printf '%b' "$FAILED_LIST" >&2
  warn "The script is idempotent — fix the issues above and re-run it."
else
  info "All work setup steps completed."
fi
cat <<'DONE'

Next: provision the loom dev loop with loom's onboarding script:
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/wvrdz/loom/main/scripts/setup-dev-env.sh)"
(installs pnpm/just/direnv/tmux, Node 24.15, shll/fab, Docker, ghcr auth, clones loom)
DONE

[[ "$FAILED_COUNT" -eq 0 ]] || exit 1
