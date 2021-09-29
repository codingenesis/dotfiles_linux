#!/bin/sh

# Comment out the "if" statement with bbswitch
# And uncomment the "if" statement with nvidia
# If you don't use bbswitch
# The escaped colours won't work with polybar

temp=0

#if [[ $(pgrep -c nvidia) -gt 1 ]]; then  # Deal with modeset after first startup
if [[ $(cat /proc/acpi/bbswitch) == *"ON"*  ]]; then
	#echo $(cat /proc/acpi/bbswitch) # Test

	temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

	if [[ $temp -lt 21 ]]; then
		#icon="\e[1;32m  \e[0m"
		icon=
	elif [[ $temp -lt 41 ]]; then
		#icon="\e[1;32m  \e[0m"
		icon=
	elif [[ $temp -lt 61 ]]; then
		#icon="\e[1;32m  \e[0m"
		icon=
	elif [[ $temp -lt 81 ]]; then
		#icon="\e[1;33m  \e[0m"
		icon=
	else
		#icon= "\e[1;31m  \e[0m"
		icon=
	fi

	#echo -e $icon $temp
	echo $icon $temp
else
	#echo -e "\e[1;32m GPU \e[0m"
	echo ""
fi

