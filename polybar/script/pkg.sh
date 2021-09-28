#!/bin/bash
pac=$(pacman -Qu | wc -l)
aur=$(pacaur --aur-check | wc -l)

check=$((pac + aur))
if [[ "$check" != "0" ]]
then
    echo "%{F#000000}PAC%{F-} %{F#d33682}$pac%{F-} %{F#000000}AUR%{F-} %{F#d33682}$aur%{F-}"
else
    echo "%{F#000000}No Update%{F-}"
fi
