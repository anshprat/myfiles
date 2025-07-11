set -x
TOTAL_TIME=10 # in minutes
INIT_PERIOD=70  # percentage as integer
MINS_REMAIN=$(((TOTAL_TIME * (100 - INIT_PERIOD)) / 100))
INIT_SECS=$(((TOTAL_TIME * INIT_PERIOD * 60) / 100))

timer() {
    local time=$1
    shift 
    local msg=$*
    sleep $time && say "$msg"
}

#

# osascript <<EOF
# tell application "Clock"
#     activate
#     delay 1
#     tell application "System Events"
#         tell process "Clock"
#             click menu item "Timers" of menu "View" of menu bar 1
#             delay 1
#             click button "Start" of group 1 of window "Clock"
#         end tell
#     end tell
# end tell
# EOF

# sleep $INIT_SECS  && say ${MINS_REMAIN} minutes to go
timer $INIT_SECS "${MINS_REMAIN} minutes to go"

SECS_REMAIN=$((MINS_REMAIN * 60))
# sleep ${SECS_REMAIN} && "${TOTAL_TIME} minutes up"
timer ${SECS_REMAIN} "${TOTAL_TIME} minutes up"

# # sleep ${SECS_REMAIN} && "${TOTAL_TIME} minutes up"
# timer ${SECS_REMAIN} "${TOTAL_TIME} minutes up"



