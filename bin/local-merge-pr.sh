#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <PR_NUMBER | PR_URL>"
  echo ""
  echo "Fetches and merges a GitHub PR into the current branch."
  echo ""
  echo "Examples:"
  echo "  $(basename "$0") 42"
  echo "  $(basename "$0") https://github.com/owner/repo/pull/42"
  exit 1
}

[[ $# -ne 1 ]] && usage

input="$1"

# Extract PR number: strip trailing slashes/fragments, grab last numeric segment after /pull/
if [[ "$input" =~ ^https?:// ]]; then
  pr_number=$(echo "$input" | grep -oE '/pull/[0-9]+' | grep -oE '[0-9]+')
  if [[ -z "$pr_number" ]]; then
    echo "Error: could not extract PR number from URL: $input" >&2
    exit 1
  fi
elif [[ "$input" =~ ^[0-9]+$ ]]; then
  pr_number="$input"
else
  echo "Error: argument must be a PR number or a GitHub PR URL" >&2
  exit 1
fi

# Derive owner/repo from git remote
remote_url=$(git remote get-url origin 2>/dev/null) || {
  echo "Error: no 'origin' remote found" >&2
  exit 1
}

# Handle SSH (git@...:owner/repo.git) and HTTPS (https://...owner/repo.git)
if [[ "$remote_url" =~ git@[^:]+:(.+)\.git$ ]]; then
  repo="${BASH_REMATCH[1]}"
elif [[ "$remote_url" =~ git@[^:]+:(.+)$ ]]; then
  repo="${BASH_REMATCH[1]}"
elif [[ "$remote_url" =~ https?://[^/]+/(.+)\.git$ ]]; then
  repo="${BASH_REMATCH[1]}"
elif [[ "$remote_url" =~ https?://[^/]+/(.+)$ ]]; then
  repo="${BASH_REMATCH[1]}"
else
  echo "Error: could not parse owner/repo from remote URL: $remote_url" >&2
  exit 1
fi

current_branch=$(git branch --show-current)
echo "Repo:   $repo"
echo "PR:     #$pr_number"
echo "Branch: $current_branch"
echo ""

# Get the PR head branch name via gh CLI
head_ref=$(gh pr view "$pr_number" --repo "$repo" --json headRefName --jq '.headRefName') || {
  echo "Error: could not fetch PR #$pr_number metadata (is gh authenticated?)" >&2
  exit 1
}
echo "Head:   $head_ref"
echo ""

# Fetch the PR head branch and update the remote tracking ref
echo "Fetching $head_ref..."
git fetch origin "$head_ref:refs/remotes/origin/$head_ref"

# Merge from remote ref
echo "Merging origin/$head_ref into $current_branch..."
git merge "origin/$head_ref" --no-edit

echo ""
echo "PR #$pr_number ($head_ref) merged into $current_branch."
