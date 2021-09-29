#!/bin/sh

if pgrep -x "compton" > /dev/null
then
	echo "%{F#000000} ON %{F-}"
else
	echo " OFF "
fi
