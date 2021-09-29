# IP addresses
alias ip="ifconfig|grep broadcast"  # List IPs
alias pubip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# View HTTP traffic

alias sniff="sudo ngrep -W byline -d 'en0' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i enp3s0 -n -s 0 -w - | grep -a -o -E \"Host\\: .*|GET \\/.*\""

alias pg="ping www.google.com"
alias ip-address='curl -s -H "Accept: application/json" https://ipinfo.io/json | jq "del(.loc, .postal, .readme)"'

alias hosts='sudo vim /etc/hosts'

# Networking. IP address, dig, DNS
alias ip2="dig +short myip.opendns.com @resolver1.opendns.com"
alias dig="dig +nocmd any +multiline +noall +answer"

# Enhanced WHOIS lookups
alias whois="whois -h whois-servers.net"

# Download file and save it with filename of remote file
alias get="curl -O -L"

# external ip address
alias myip_dns="dig +short myip.opendns.com @resolver1.opendns.com"
alias myip_http="GET http://ipecho.net/plain && echo"

# show dns info via "dig"
alias dnsInfo="digga"

# speedtest: get a 100MB file via wget
alias speedtest="wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip"

# Gzip-enabled `curl`
alias gurl="curl --compressed"

# displays the ports that use the applications
alias lsport='sudo lsof -i -T -n'

# shows more about the ports on which the applications use
alias llport='netstat -nape --inet --inet6'

# show only active network listeners
alias netlisteners='sudo lsof -i -P | grep LISTEN'

