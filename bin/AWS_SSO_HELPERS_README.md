# AWS SSO Helper Scripts

Two powerful utility scripts to streamline your AWS SSO workflow across multiple accounts.

## Scripts Overview

### 1. `aws-sso-check` - Session Validator
Checks if your AWS SSO session is valid and automatically renews it if expired.

### 2. `awsp` - Profile Switcher
Intelligently switches between AWS profiles with automatic SSO validation and session management.

---

## Installation

Scripts are installed in: `~/bin/`

Ensure `~/bin` is in your PATH. Add to your `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$HOME/bin:$PATH"
```

Reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc
```

---

## Usage Guide

### `aws-sso-check` - Validate SSO Session

**Basic Usage:**
```bash
# Check default profile (weaver-admin)
aws-sso-check

# Check specific profile
aws-sso-check weaver-prod-workload
```

**What it does:**
- Validates if SSO session is active for the specified profile
- Shows current account and identity information
- Automatically initiates SSO login if session is expired
- Uses `--sso-session` to refresh all profiles at once

**Output:**
```
✓ SSO session is valid for profile: weaver-admin
Account: 484907493020
Identity: arn:aws:sts::484907493020:assumed-role/AWSReservedSSO_AdministratorAccess_d20dca9832cca208/anshu@weaverapp.ai
```

---

### `awsp` - Profile Switcher

**Interactive Mode (Recommended):**
```bash
awsp
```
Presents a numbered list of all profiles with status indicators. Simply enter the number to select.

**Direct Profile Selection:**
```bash
awsp weaver-prod-workload
```

**List All Profiles:**
```bash
awsp -l
# or
awsp --list
```
Shows all available profiles with:
- ✓ = Valid SSO session
- ✗ = Invalid/expired session
- Account ID
- Role name

**Show Profile Info:**
```bash
awsp -i weaver-admin
# or
awsp --info weaver-admin
```
Displays detailed information about a specific profile.

**Export to Environment (Recommended):**
```bash
eval $(awsp -e weaver-admin)
```
Sets `AWS_PROFILE` environment variable in your current shell.

**Help:**
```bash
awsp -h
# or
awsp --help
```

---

## Workflow Examples

### Example 1: Quick Profile Switch
```bash
# Interactive selection with auto-validation
awsp

# Select profile #3 from the list
# Script automatically:
# - Validates SSO session
# - Renews if expired
# - Shows you the export command
```

### Example 2: Automated Script Usage
```bash
#!/bin/bash
# Your automation script

# Ensure SSO session is valid
aws-sso-check weaver-prod-workload

# Set profile and run commands
export AWS_PROFILE=weaver-prod-workload
aws s3 ls
aws ec2 describe-instances
```

### Example 3: Quick Environment Setup
```bash
# One-liner to switch profile and set environment
eval $(awsp -e weaver-nonprod-workload)

# Now all AWS CLI commands use this profile
aws sts get-caller-identity
```

### Example 4: Daily Workflow
```bash
# Morning: Check status of all profiles
awsp -l

# See which sessions need renewal (marked with ✗)
# Renew all sessions at once
aws sso login --sso-session wvrdz

# Switch to working profile
eval $(awsp -e weaver-dev-lab)

# Proceed with your work
```

---

## Advanced Features

### Session Management
Both scripts use the SSO session (`wvrdz`) to refresh all profiles simultaneously, reducing the number of browser logins required.

### Status Indicators
- **Green ✓**: SSO session is valid and active
- **Red ✗**: SSO session is expired or invalid
- Color-coded output for easy visual scanning

### Automatic Renewal
If a profile's session is expired, the scripts automatically:
1. Detect the expired session
2. Initiate SSO login via browser
3. Refresh credentials for ALL profiles (not just one)
4. Verify the session is now valid

---

## Your AWS Profiles

Current configured profiles:
- `weaver-admin` (Account: 484907493020) - Admin account
- `weaver-tooling-workload` (Account: 495440871673) - Tooling/CI-CD
- `weaver-nonprod-workload` (Account: 166185345353) - Non-production
- `weaver-prod-workload` (Account: 717466749063) - Production
- `weaver-dev-lab` (Account: 386706333173) - Development/testing

All use SSO session: `wvrdz`
SSO URL: https://weaverapp.awsapps.com/start/

---

## Troubleshooting

### "Profile not found" Error
```bash
# Check available profiles
awsp -l

# Verify AWS config
cat ~/.aws/config
```

### SSO Login Keeps Failing
```bash
# Clear SSO cache and try again
rm -rf ~/.aws/sso/cache/*
aws sso login --sso-session wvrdz
```

### Profile Exists But Can't Access
```bash
# Check if you have access to the account in Identity Center
# Contact your AWS administrator if you should have access

# Verify your SSO session
aws-sso-check [profile-name]
```

### Need to Force Re-authentication
```bash
# Logout and login again
aws sso logout
aws sso login --sso-session wvrdz
```

---

## Tips & Best Practices

1. **Use `eval $(awsp -e profile)` for environment export** - This properly sets AWS_PROFILE in your current shell

2. **Run `awsp -l` daily** - Quickly see which profiles need session renewal

3. **Prefer SSO session login** - Use `aws sso login --sso-session wvrdz` instead of per-profile login to refresh all profiles at once

4. **Add to shell startup** - Add these functions to your `.bashrc`/`.zshrc`:
   ```bash
   # Quick profile switch
   alias awsl='awsp -l'
   alias awsi='awsp'

   # Auto-export function
   awse() {
       eval $(awsp -e "$1")
   }
   ```

5. **Script Integration** - Always validate SSO before AWS operations:
   ```bash
   aws-sso-check "$AWS_PROFILE" || exit 1
   # ... your AWS commands
   ```

---

## Comparison: Old vs New Workflow

### Old Workflow (Manual)
```bash
# Set profile
export AWS_PROFILE=weaver-prod-workload

# Try command
aws s3 ls
# Error: expired token

# Login to specific profile
aws sso login --profile weaver-prod-workload
# (Opens browser)

# Try again
aws s3 ls
```

### New Workflow (Automated)
```bash
# Switch and validate in one step
eval $(awsp -e weaver-prod-workload)
# Automatically detects expired session and renews if needed

# Just works
aws s3 ls
```

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Run commands with `-h` or `--help` flag
3. Verify your AWS SSO configuration in `~/.aws/config`

---

**Created:** November 2025
**Last Updated:** November 2025
**Version:** 1.0
