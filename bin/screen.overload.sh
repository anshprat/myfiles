#screen commands shortcut

args=$@

# First check if the arg starts with a "-", if yes, then simply pass on the whole arg to screen


# if no, check screen -ls to see if a session with that name exists, if yes, attach to it, else create a new session with that name
if [[ $args == -* ]]; then
  screen "$@"
else
  session_exists=$(screen -ls | grep -w "$args")
  if [[ -n $session_exists ]]; then
    screen -dr "$args"
  else
    screen -S "$args"
  fi
fi