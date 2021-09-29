#!/bin/sh

if pgrep -x "compton" > /dev/null
then
	echo "%{F#acaccb} ON %{F-}"
else
	echo " OFF "
fi
