#!/bin/sh

if [ "$(pgrep openvpn)" ]; then
    echo "%{F#000000} VPN%{F-} %{F#446d04}ON  %{F-}"
else
    echo "%{F#000000} VPN%{F-} %{F#881a08}OFF  %{F-}"
fi
