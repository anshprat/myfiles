#!/bin/zsh
set -x
# <xbar.title>ping</xbar.title>
# <xbar.version>v1.1</xbar.version>
# <xbar.author>Anshu Prateek</xbar.author>
# <xbar.author.github>anshprat</xbar.author.github>
# <xbar.desc>Checks local site reachability and shows MFA</xbar.desc>
# <xbar.image>data:image/jpeg;base64,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</xbar.image>
# <xbar.dependencies>ping</xbar.dependencies>


# plugin templated from https://xbarapp.com/docs/plugins/Network/ping.10s.sh.html
# Themes copied from here: http://colorbrewer2.org/
# shellcheck disable=SC2034
PURPLE_GREEN_THEME=("#762a83" "#9970ab" "#c2a5cf" "#a6dba0" "#5aae61" "#1b7837")
# shellcheck disable=SC2034
RED_GREEN_THEME=("#d73027" "#fc8d59" "#fee08b" "#d9ef8b" "#91cf60" "#1a9850")
# shellcheck disable=SC2034
ORIGINAL_THEME=("#acacac" "#ff0101" "#cc673b" "#ce8458" "#6bbb15" "#0ed812")

# Configuration
COLORS=(${RED_GREEN_THEME[@]})
MENUFONT="" #size=10 font=UbuntuMono-Bold"
FONT=""

VAR_FOLDER="$HOME/tmp/var"
LOG_FOLDER=logs
LOG_FILE="$VAR_FOLDER/${LOG_FOLDER}/mfapy.log"
VPN_LOCK_FILE=${VAR_FOLDER}/${LOG_FOLDER}/vpn.lock

_SELF_SCRIPT=$0

log() {
level=$1
shift  
msg=$@
echo "["$(date)"]" "["$level"]" $msg >> $LOG_FILE
}

source ~/bin/internal-vars.sh
ok=0
no=1

i=1
while [[ $# -gt 0 ]]; do
  eval "param$i=\$1"
  shift
  ((i++))
done

curl -IsL -m 1 "https://${JIRA_SITE_202407}/plugins/servlet/samlsso?redirectTo=%2F" | grep "HTTP/2 200" >/dev/null
healthcheck_status=$?
if [[ $healthcheck_status == $ok ]]
then
  VPN_STATUS=🟢
  if [ ! -f $VPN_LOCK_FILE ]
  then
    touch $VPN_LOCK_FILE
    log "INFO" "jira healthcheck ok"
  fi
else
  VPN_STATUS=🔴
  if [ -f $VPN_LOCK_FILE ]
  then 
    rm $VPN_LOCK_FILE
    log "INFO" "jira healthcheck failed"
  fi
fi

'''
Is healthcheck redundant here? Or does it help to fail faster and allow to check for server?
Can we do this only with get_mfa?
'''
curl -s -I -m 1 https://${LOCALSITE_202407}/healthcheck | grep 200 >/dev/null
healthcheck_status=$?

get_mfa() {
  curl -s https://${LOCALSITE_202407}/mfa | /opt/homebrew/bin/jq -r '.output'
}

if [[ $healthcheck_status == $ok ]]
then
  # MFA_STATUS=🟢
  MFA_STATUS=$(get_mfa)
else
  MFA_STATUS=🟡
  source $HOME/.venv/mfa/bin/activate
  nohup python3 $HOME/code/anshprat/mfa-extension/mfa.py >> $LOG_FILE 2>&1 &
fi

if [[ "$param1" = "copy_mfa" ]]; then
# Getting MFA again to ensure we get latest MFA
  echo $(get_mfa) | pbcopy
  MFA=`pbpaste`
  # osascript -e "display notification \"MFA $MFA copied\" with title \"Xbar MFA Copy\"" &> /dev/null
  # exit
fi

if [[ "$param1" = "open_vpn" ]]; then
  open /Applications/BIG-IP\ Edge\ Client.app
  log "INFO" "vpn opened"
fi


get_proxy_cmd_menu(){
  # This $1 is local function call param, not global $1
  PROXY_ACTION=$1
  echo "$PROXY_ACTION ssh_proxy | bash='${_SELF_SCRIPT}' param1=ssh_proxy param2=$PROXY_ACTION terminal=false"
}

##
# SSH TUNNEL PROXY Check and Enable
proxy_cmd="ssh $TUNNEL_SSH_HOST_202407 -i $HOME/.ssh/v1-signed-anshu.prateek.key -D 1080 -fN"

check_proxy() {
  ps aux| grep "$proxy_cmd"|grep -v grep >/dev/null
  PROXY_STATUS=$?
  if [[ $PROXY_STATUS == $ok ]]
  then
    PROXY_STATUS_INDICATOR=🟢
    PROXY_ACTION=stop
  else
    PROXY_STATUS_INDICATOR=🔴
    PROXY_ACTION=start
  fi
  PROXY_CMD_MENU=$(get_proxy_cmd_menu $PROXY_ACTION)

  if [[ "$VPN_STATUS" = 🔴 ]]
  then
    stop_proxy
    PROXY_CMD_MENU="open vpn |  bash='${_SELF_SCRIPT}' param1=open_vpn terminal=false "
  fi
  
}

stop_proxy() {
  ps aux| grep "$proxy_cmd"|grep -v grep|awk '{print $2}'|xargs -I Id kill Id {} \;
}

if [[ "$param1" = "ssh_proxy" ]]
then
  case $param2 in
  
  "start"|"restart")
  stop_proxy
  if [[ "$VPN_STATUS" = 🔴 ]]
  then
    osascript -e "display notification \"VPN is not running, please start VPN before ssh_tunnel\" with title \"Xbar MFA/VPN\"" &> /dev/null
  else
    eval $proxy_cmd
  fi
  ;;
  
  "stop")
  stop_proxy
  ;;

esac
fi

check_proxy
##

echo "$VPN_STATUS  $PROXY_STATUS_INDICATOR  $MFA_STATUS | $MENUFONT"
echo "---"
echo $MFA_STATUS

echo "---"
echo "Refresh... | refresh=true"

if [[ $MFA_STATUS != 🟡 ]]
then
  echo "copy $MFA_STATUS | bash='${_SELF_SCRIPT}' param1=copy_mfa terminal=false"
fi

echo "$PROXY_CMD_MENU"
if [[ $PROXY_ACTION == "stop" ]]
then
  get_proxy_cmd_menu restart
fi



