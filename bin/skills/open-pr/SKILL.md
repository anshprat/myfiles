---
name: open-pr
description: "Find the pull request for the branch checked out in a folder (default: the current directory) and open it in the browser. Use when asked to open the PR, show the PR, link the PR, or 'which PR am I on' for a repo, worktree or folder. Also usable from the shell as `open-pr [DIR]`."
allowed-tools: Bash
metadata:
  version: 1.0.0
  requires:
    bins: [gh, git]
---

# open-pr

Script: `open-pr` in this folder. It is on PATH through `~/bin/open-pr`.

## When to use

- The user asks to open, show or link the PR for a folder, repo, worktree or "this branch".
- The user gives a path: run the script against that path. No path: use the current working directory.
- Do not use it to create a PR. It only finds and opens an existing one.

## Steps

1. Run `open-pr DIR` (DIR optional, a folder or a file inside a git checkout).
   The script reads the checked-out branch in DIR, looks up its PR with `gh`,
   prints one line `#N  title  (STATE)  URL`, and opens the URL in the browser.
2. Report that line (number, title, state, URL) to the user.

## Flags

- `-u` / `--url`: print the PR URL only. The browser does not open.
  Use it when the URL feeds another step, or when the user cannot see the local
  browser. In a HexoKit remote session run `rk present "$(open-pr -u DIR)"` instead
  of opening the local browser (see `shll skill hexokit`).

## Exit codes

| Exit | Meaning | What to do |
|------|---------|------------|
| 0 | PR found and opened | Report the printed line. |
| 1 | The branch has no PR | Report the branch name from stderr. Offer `gh pr create` (push the branch first if stderr says it has no upstream). Do not create the PR unless the user asks. |
| 2 | Usage error: not a git repo, detached HEAD, `gh` missing, or `gh` cannot reach the repo | Report the stderr message. |

## Multiple GitHub accounts

If `gh` cannot see the repo with the active account, the script tries each other
logged-in account with `gh auth switch`. It prints which account it switched to.
If every account fails, the script restores the original account and exits 2.
Then run `gh auth status`, pick the right account with `gh auth switch --user NAME`,
and run `open-pr DIR` again.

## Examples

```bash
open-pr                       # PR for the branch in the current directory
open-pr ~/code/noon/loom      # PR for the branch checked out in that repo
open-pr -u ../wt/feat-x       # print the URL only
```
