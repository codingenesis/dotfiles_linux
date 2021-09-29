#!/bin/sh

if [ "$(pgrep openvpn)" ]; then
    echo "%{F#acaccb} VPN%{F-} %{F#446d04}ON  %{F-}"
else
    echo "%{F#acaccb} VPN%{F-} %{F#ff6200}OFF  %{F-}"
fi
