#!/bin/sh

UI_PID="$(pgrep -f "OptionSelectUI.py")"

kill "$UI_PID"