#!/bin/bash

# <xbar.title>Active WIFI Signal</xbar.title>
# <xbar.author>Bryan Stone</xbar.author>
# <xbar.author.github>aegixx</xbar.author.github>
# <xbar.desc>Displays currently connected WIFI Signal</xbar.desc>

# Themes copied from here: http://colorbrewer2.org/
# shellcheck disable=SC2034
RED_GREEN_THEME=("#d73027" "#fc8d59" "#fee08b" "#ffffbf" "#d9ef8b" "#91cf60" "#1a9850")
COLORS=("${RED_GREEN_THEME[@]}")

WIFIDATA=$(sudo /usr/bin/wdutil info wifi)
# WIFIDATA=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}' | xargs networksetup -getairportnetwork|awk '{print $4}')
SSID=$(echo "$WIFIDATA" | awk '/ SSID/ {print substr($0, index($0, $3))}')
SIGNAL_N=$(echo "$WIFIDATA" | awk '/ RSSI/ {print substr($0, index($0, $3))}')
NOISE_N=$(echo "$WIFIDATA" | awk '/ Noise/ {print substr($0, index($0, $3))}')
SIGNAL=$(echo "$SIGNAL_N" | awk '{print $1}')
NOISE=$(echo "$NOISE_N" | awk '{print $1}')

SNR="$((SIGNAL - NOISE))"

# Signal Strength – 0dBm (strongest) and --100dBm (weakest). 
## -30 dBm  Amazing
## -50 dBm	Excellent
## -60 dBm	Good
## -67 dBm	Reliable
## -70 dBm	Okay
## -80 dBm	Not Good
## -90 dBm	Unusable
if (("$SIGNAL" >= -30)); then
    RATING="Amazing"
    COLOR=${COLORS[6]}
elif (("$SIGNAL" >= -50)); then
    RATING="Excellent"
    COLOR=${COLORS[5]}
elif (("$SIGNAL" >= -60)); then
    RATING="Good"
    COLOR=${COLORS[4]}
elif (("$SIGNAL" >= -67)); then
    RATING="Reliable"
    COLOR=${COLORS[3]}
elif (("$SIGNAL" >= -70)); then
    RATING="Okay"
    COLOR=${COLORS[2]}
elif (("$SIGNAL" >= -80)); then
    RATING="Not Good"
    COLOR=${COLORS[1]}
elif (("$SIGNAL" >= -90)); then
    RATING="Unusable"
    COLOR=${COLORS[0]}
else
    RATING="Unknown"
    COLOR="#ccc"
fi

# Signal Quality - quality ~= 2* (dBm + 100)
## High quality: 90% ~= -55dBm
## Medium quality: 50% ~= -75dBm
## Low quality: 30% ~= -85dBm
## Unusable quality: 8% ~= -96dBm
QUALITY="$((2 * SNR))"
QUALITY="$((QUALITY < 100 ? QUALITY : 100))"

IP=$(curl -s ifconfig.co)
#  | xargs -I id whois id \;|grep netname|awk '{print $2}'
IP_HASH=$(echo $IP|md5)

CACHE_DIR=$HOME/tmp/var/cache

cache_file=${CACHE_DIR}/${IP_HASH}.txt

if [ ! -f $cache_file ]
then
    echo $IP | xargs -I id whois id \;|grep netname|awk '{print $2}' > $cache_file
    echo $IP >> $cache_file
fi

ISP=$(cat $cache_file)

LINES="
$ISP
Signal: $SIGNAL dbM ($RATING)
Quality: $QUALITY% ($SNR dBm SNR)
"

echo "$SSID"
echo "---"

while read -r line; do
  if ! [ "$line" == "" ]; then
    echo "$line | bash='/bin/bash' param1='-c' param2='/bin/echo $line | pbcopy' terminal=false"
  fi
done <<< "$LINES"

echo "---"
echo "Refresh... | refresh=true"