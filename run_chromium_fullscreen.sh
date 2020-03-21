#!/bin/bash
xset s noblank
xset s off
xset -dpms
unclutter -idle 0.5 -root &
set -x
c=0
while [ 1 ]
do
  ps aux|grep chromium-browser|grep -v grep
  is_chromium_not_running=$?
  if [ ${is_chromium_not_running} -eq 1 ]
  then
      sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
      sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences
      sleep 1
      chromium-browser --start-fullscreen --enable-kiosk-mode --noerrdialogs --disable-infobars --kiosk \
      "https://grabpay.atlassian.net/plugins/servlet/Wallboard/?dashboardId=10113" \
      "https://grafana.grabpay.com/d/StbQwXMZz/gfg-stability-master?orgId=1&refresh=30s&kiosk" \
      "https://app.datadoghq.com/dashboard/hx2-ayv-5pa/gfg-stability-comms?tv_mode=true" \
      &>/dev/null &
  fi
  # xdotool search --onlyvisible --class chromium key ctrl+Tab
  xdotool keydown ctrl+Tab; xdotool keyup ctrl+Tab;
  sleep 60
  let c=c+1
  curl -s -i "https://api.grabpay.com/monitor/pi?auth=anshu&client=chrome&id=`date +%s`&c=${c}"
done
