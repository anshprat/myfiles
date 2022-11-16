#!/bin/bash
# set -x
# <xbar.title>Grab VPN</xbar.title>
# <xbar.dependencies>bash</xbar.dependencies>
# <xbar.author>Anshu Prateek</xbar.author>
# <xbar.author.github>anshprat</xbar.author.github>
# <xbar.desc>Grab VPN Connect/</xbar.desc>

SCRIPT_PATH=$(pwd)
PARENT_COMMAND=$(ps $PPID | tail -n 1 | awk "{print \$5}")

function vpn_status {
    connected_status=`/opt/cisco/anyconnect/bin/vpn status|grep state|awk '{print $4}'|sort|uniq`
    echo $connected_status
}

function notify {
    message=$1
    terminal-notifier -title "Cisco AnyConnect via XBar" -subtitle "Auto Connect" -sound default -message "$message" 
}
param1=$1

if [ ! -z $param1 ]
then
    if [[ "$param1" = "connect" ]]; then
        osascript  -e 'quit app "Cisco AnyConnect Secure Mobility Client"'
        notify "Please approve Duo Push for VPN connection"
        /Users/anshup/bin/gvpn
        /usr/bin/open xbar://app.xbarapp.com/refreshAllPlugins
        is_connected=$(vpn_status)
        if [ "$is_connected" == "Connected" ]
        then
            vpn_status_msg="ed"
        else
            vpn_status_msg="ion failed "
        fi
        status_message="VPN Connect${vpn_status_msg}, closing terminal"
        notify "$status_message" 
        # osascript  -e 'tell application "Terminal" to close (get window 1)'
    

    elif [[ "$param1" = "disconnect" ]]; then
    /opt/cisco/anyconnect/bin/vpn disconnect
    osascript -e 'quit app "Cisco AnyConnect Secure Mobility Client"'
    fi
fi


is_connected=$(vpn_status)

if [ "$is_connected" == "Disconnected" ]
then
status=🔴
action="Connect | terminal=true  shell='$SCRIPT_PATH/$0' param1=connect  refresh=false"
fi

if [ "$is_connected" == "Connected" ]
then
status=🟢
action="Disconnect | terminal=false shell='$0' param1=disconnect refresh=true"
fi

if [ $PARENT_COMMAND == '/Applications/xbar.app/Contents/MacOS/xbar' ]
then
    echo "VPN $status"
    echo "---"
    echo $action
fi