#!/bin/bash
# <xbar.title>Grab VPN</xbar.title>
# <xbar.dependencies>bash</xbar.dependencies>
# <xbar.author>Anshu Prateek</xbar.author>
# <xbar.author.github>anshprat</xbar.author.github>
# <xbar.desc>Grab VPN Connect/</xbar.desc>

SCRIPT_PATH=$(pwd)
PARENT_COMMAND=$(ps $PPID | tail -n 1 | awk "{print \$5}")
common_wait_time=3
set -x

param1=${1}
vpngroup=${2:-3}
use_terminal=${3:-true}
log_user=${5:-0}
DEBUG=${4:-false}

function vpn_status {
    connected_status=$(/opt/cisco/anyconnect/bin/vpn status | grep state | awk '{print $4}' | sort | uniq)
    echo $connected_status
}

function notify {
    message=$1
    /opt/homebrew/bin/terminal-notifier -title "Cisco AnyConnect via XBar" -subtitle "Easy Connect" -group com.anshuprateek.vpn.notify -ignoreDnD -message "$message" -sender com.job.net 1>/dev/null

}

function remind {
    is_connecting=1
    while [[ $is_connecting -gt 0 || $is_security_wait -gt 0 ]]; do
        sleep $common_wait_time
        is_security_wait=$(ps aux | grep "security find-generic-password -s bitwarden -w" | grep -v grep | wc -l | awk '{$1=$1;print}')
        if [ $is_security_wait -ge 1 ]; then
            notify "Please approve password"
            continue
        fi
        sleep $common_wait_time
        is_connecting=$(ps aux | grep "/opt/cisco/anyconnect/bin/vpn -s connect" | grep -v grep | wc -l | awk '{$1=$1;print}')

        if [ $is_connecting -ge 1 ]; then
            notify "Please approve Duo"
            continue
        fi
    done

}

if [ ! -z $param1 ]; then
    if [[ "$param1" = "connect" ]]; then
        osascript -e 'quit app "Cisco AnyConnect Secure Mobility Client"'
        # remind &
        /Users/anshup/bin/vpn.expect $vpngroup $log_user
        rc=$?
        # echo $rc >> /Users/$(whoami)/tmp/vpn.xbar.log
        if [ $rc -eq 181 ]; then
            notify "Failed to capture biometrics, please retry"
            sleep $common_wait_time
            ps aux|grep vpn|grep -v grep|grep $(whoami)|grep -v tail|awk '{print $2}'|xargs -I id kill id
        fi
        is_connected=$(vpn_status)
        if [ "$is_connected" == "Connected" ]
        then
            vpn_status_msg="ed"
        else
            vpn_status_msg="ion failed "
        fi
        status_message="VPN Connect${vpn_status_msg}"
        /usr/bin/open xbar://app.xbarapp.com/refreshAllPlugins
        notify "$status_message"
        # Waiting to let the while loop exit for a clean close of terminal
        sleep $common_wait_time
        if [ $use_terminal == true ] && [ $DEBUG == false ]; then
            osascript  -e 'tell application "Terminal" to close (get window 1)'
        fi

    elif [[ "$param1" = "disconnect" ]]; then
        /opt/cisco/anyconnect/bin/vpn disconnect 
        osascript -e 'quit app "Cisco AnyConnect Secure Mobility Client"'
    fi
fi

is_connected=$(vpn_status)

if [ $PARENT_COMMAND == '/Applications/xbar.app/Contents/MacOS/xbar' ]; then
    if [ "$is_connected" == "Disconnected" ]; then
        status=🔴
        action="Connect Remote_Access_VPN_GFG | terminal='$use_terminal'  shell='$SCRIPT_PATH/$0' param1=connect param2=3 refresh=true"
        action2="Connect Remote_Access_VPN | terminal='$use_terminal'  shell='$SCRIPT_PATH/$0' param1=connect param2=2  refresh=true"

    # ACTION
    fi

    if [ "$is_connected" == "Connected" ]; then
        status=🟢
        action="Disconnect | terminal=false shell='$0' param1=disconnect refresh=true"
    fi

    echo "VPN $status"
    echo "---"
    echo $action
    if [ "${action2}0" != "0" ]; then
        echo $action2
    fi
fi
