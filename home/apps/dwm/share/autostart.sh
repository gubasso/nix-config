#!/bin/sh
# WM-coupled daemons — restarted each time dwm starts.

run() {
  pkill -x "$(basename "$1")" 2>/dev/null
  sleep 0.1
  "$@" &
}

run sxhkd
# run picom
