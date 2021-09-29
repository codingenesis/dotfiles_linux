#!/bin/sh

#The command for starting compton
#always keep the -b argument!
COMPTON="compton -b --config ~/.config/i3/compton.conf"

if pgrep -x "compton" > /dev/null
then
	killall compton
else
	$COMPTON
fi
