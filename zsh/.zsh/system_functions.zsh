


# Create a new directory and enter it
mkd() {
	mkdir -p "$@"
	cd "$@" || exit
}

# Make a temporary directory and enter it
tmpd() {
	local dir
	if [ $# -eq 0 ]; then
		dir=$(mktemp -d)
	else
		dir=$(mktemp -d -t "${1}.XXXXXXXXXX")
	fi
	cd "$dir" || exit
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
targz() {
	local tmpFile="${1%/}.tar"
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${1}" || return 1

	size=$(
	stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
	stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
	)

	local cmd=""
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use
it
		cmd="zopfli"
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz"
		else
			cmd="gzip"
		fi
	fi

	echo "Compressing .tar using \`${cmd}\`…"
	"${cmd}" -v "${tmpFile}" || return 1
	[ -f "${tmpFile}" ] && rm "${tmpFile}"
	echo "${tmpFile}.gz created successfully."
}

# Use Git’s colored diff when available
#if hash git &>/dev/null ; then
#	diff() {
#		git diff --no-index --color-words "$@"
#	}
#fi

# Create a git.io short URL
gitio() {
	if [ -z "${1}" ] || [ -z "${2}" ]; then
		echo "Usage: \`gitio slug url\`"
		return 1
	fi
	curl -i https://git.io/ -F "url=${2}" -F "code=${1}"
}

# Compare original and gzipped file size
gz() {
	local origsize
	origsize=$(wc -c < "$1")
	local gzipsize
	gzipsize=$(gzip -c "$1" | wc -c)
	local ratio
	ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
	printf "orig: %d bytes\\n" "$origsize"
	printf "gzip: %d bytes (%2.2f%%)\\n" "$gzipsize" "$ratio"
}

# Run `dig` and display the most useful info
digga() {
	dig +nocmd "$1" any +multiline +noall +answer
}

# Query Wikipedia via console over DNS
mwiki() {
	dig +short txt "$*".wp.dg.cx
}

# UTF-8-encode a string of Unicode symbols
escape() {
	local args
	mapfile -t args < <(printf "%s" "$*" | xxd -p -c1 -u)
	printf "\\\\x%s" "${args[@]}"
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi
}

# Decode \x{ABCD}-style Unicode escape sequences
unidecode() {
	perl -e "binmode(STDOUT, ':utf8'); print \"$*\""
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi
}

# Get a character’s Unicode code point
codepoint() {
	perl -e "use utf8; print sprintf('U+%04X', ord(\"$*\"))"
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
getcertnames() {
	if [ -z "${1}" ]; then
		echo "ERROR: No domain specified."
		return 1
	fi

	local domain="${1}"
	echo "Testing ${domain}…"
	echo ""; # newline

	local tmp
	tmp=$(echo -e "GET / HTTP/1.0\\nEOT" \
		| openssl s_client -connect "${domain}:443" 2>&1)

	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
		local certText
		certText=$(echo "${tmp}" \
			| openssl x509 -text -certopt "no_header, no_serial,
no_version, \
			no_signame, no_validity, no_issuer, no_pubkey, no_sigdump,
no_aux")
		echo "Common Name:"
		echo ""; # newline
		echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//"
		echo ""; # newline
		echo "Subject Alternative Name(s):"
		echo ""; # newline
		echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
			| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\\n" | tail -n
+2
		return 0
	else
		echo "ERROR: Certificate not found."
		return 1
	fi
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
v() {
	if [ $# -eq 0 ]; then
		vim .
	else
		vim "$@"
	fi
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
o() {
	if [ $# -eq 0 ]; then
		xdg-open .	> /dev/null 2>&1
	else
		xdg-open "$@" > /dev/null 2>&1
	fi
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tre() {
	tree -aC -I '.git' --dirsfirst "$@" | less -FRNX
}

# Call from a local repo to open the repository on github/bitbucket in browser
# Modified version of https://github.com/zeke/ghwd
repo() {
	# Figure out github repo base URL
	local base_url
	base_url=$(git config --get remote.origin.url)
	base_url=${base_url%\.git} # remove .git from end of string

	# Fix git@github.com: URLs
	base_url=${base_url//git@github\.com:/https:\/\/github\.com\/}

	# Fix git://github.com URLS
	base_url=${base_url//git:\/\/github\.com/https:\/\/github\.com\/}

	# Fix git@bitbucket.org: URLs
	base_url=${base_url//git@bitbucket.org:/https:\/\/bitbucket\.org\/}

	# Fix git@gitlab.com: URLs
	base_url=${base_url//git@gitlab\.com:/https:\/\/gitlab\.com\/}

	# Validate that this folder is a git folder
	if ! git branch 2>/dev/null 1>&2 ; then
		echo "Not a git repo!"
		exit $?
	fi

	# Find current directory relative to .git parent
	full_path=$(pwd)
	git_base_path=$(cd "./$(git rev-parse --show-cdup)" || exit 1; pwd)
	relative_path=${full_path#$git_base_path} # remove leading git_base_path
from working directory

	# If filename argument is present, append it
	if [ "$1" ]; then
		relative_path="$relative_path/$1"
	fi

	# Figure out current git branch
	# git_where=$(command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
	git_where=$(command git name-rev --name-only --no-undefined --always HEAD)
2>/dev/null

	# Remove cruft from branchname
	branch=${git_where#refs\/heads\/}

	[[ $base_url == *bitbucket* ]] && tree="src" || tree="tree"
	url="$base_url/$tree/$branch$relative_path"


	echo "Calling $(type open) for $url"

	open "$url" &> /dev/null || (echo "Using $(type open) to open URL failed." && exit 1);
}

# Get colors in manual pages
#man() {
#	env \
#		LESS_TERMCAP_mb="$(printf '\e[1;31m')" \
#		LESS_TERMCAP_md="$(printf '\e[1;31m')" \
#		LESS_TERMCAP_me="$(printf '\e[0m')" \
#		LESS_TERMCAP_se="$(printf '\e[0m')" \
#		LESS_TERMCAP_so="$(printf '\e[1;44;33m')" \
#		LESS_TERMCAP_ue="$(printf '\e[0m')" \
#		LESS_TERMCAP_us="$(printf '\e[1;32m')" \
#		man "$@"
#}

# Use feh to nicely view images
openimage() {
	local types='*.jpg *.JPG *.png *.PNG *.gif *.GIF *.jpeg *.JPEG'

	cd "$(dirname "$1")" || exit
	local file
	file=$(basename "$1")

	feh -q "$types" --auto-zoom \
		--sort filename --borderless \
		--scale-down --draw-filename \
		--image-bg black \
		--start-at "$file"
}

# get dbus session
dbs() {
	local t=$1
	if [[  -z "$t" ]]; then
		local t="session"
	fi

	dbus-send --$t --dest=org.freedesktop.DBus \
		--type=method_call	--print-reply \
		/org/freedesktop/DBus org.freedesktop.DBus.ListNames
}

# check if uri is up
isup() {
	local uri=$1

	if curl -s --head  --request GET "$uri" | grep "200 OK" > /dev/null ; then
 		notify-send --urgency=critical "$uri is down"
	else
		notify-send --urgency=low "$uri is up"
	fi
}

# build go static binary from root of project
gostatic(){
	local dir=$1
	local arg=$2

	if [[ -z $dir ]]; then
		dir=$(pwd)
	fi

	local name
	name=$(basename "$dir")
	(
	cd "$dir" || exit
	export GOOS=linux
	echo "Building static binary for $name in $dir"

	case $arg in
		"netgo")
			set -x
			go build -a \
				-tags 'netgo static_build' \
				-installsuffix netgo \
				-ldflags "-w" \
				-o "$name" .
			;;
		"cgo")
			set -x
			CGO_ENABLED=1 go build -a \
				-tags 'cgo static_build' \
				-ldflags "-w -extldflags -static" \
				-o "$name" .
			;;
		*)
			set -x
			CGO_ENABLED=0 go build -a \
				-installsuffix cgo \
				-ldflags "-w" \
				-o "$name" .
			;;
	esac
	)
}

# go to a folder easily in your gopath
gogo(){
	local d=$1

	if [[ -z $d ]]; then
		echo "You need to specify a project name."
		return 1
	fi

	if [[ "$d" == github* ]]; then
		d=$(echo "$d" | sed 's/.*\///')
	fi
	d=${d%/}

	# search for the project dir in the GOPATH
	mapfile -t path < <(find "${GOPATH}/src" \( -type d -o -type l \) -iname
"$d"  | awk '{print length, $0;}' | sort -n | awk '{print $2}')

	if [ "${path[0]}" == "" ] || [ "${path[*]}" == "" ]; then
		echo "Could not find a directory named $d in $GOPATH"
		echo "Maybe you need to 'go get' it ;)"
		return 1
	fi

	# enter the first path found
	cd "${path[0]}" || return 1
}

golistdeps(){
	(
	if [[ ! -z "$1" ]]; then
		gogo "$@"
	fi

	go list -e -f '{{join .Deps "\n"}}' ./... | xargs go list -e -f '{{if not
.Standard}}{{.ImportPath}}{{end}}'
	)
}

# get the name of a x window
xname(){
	local window_id=$1

	if [[ -z $window_id ]]; then
		echo "Please specifiy a window id, you find this with 'xwininfo'"

		return 1
	fi

	local match_string='".*"'
	local match_qstring='"[^"\\]*(\\.[^"\\]*)*"' # NOTE: Adds 1 backreference

	# get the name
	xprop -id "$window_id" | \
		sed -nr \
		-e "s/^WM_CLASS\\(STRING\\) = ($match_qstring),
($match_qstring)$/instance=\\1\\nclass=\\3/p" \
		-e "s/^WM_WINDOW_ROLE\\(STRING\\) =
($match_qstring)$/window_role=\\1/p" \
		-e "/^WM_NAME\\(STRING\\) = ($match_string)$/{s//title=\\1/; h}" \
		-e "/^_NET_WM_NAME\\(UTF8_STRING\\) =
($match_qstring)$/{s//title=\\1/; h}" \
		-e "\${g; p}"
}

#dell_monitor() {
#	xrandr --newmode "3840x2160_30.00"  338.75  3840 4080 4488 5136  2160 2163
#2168 2200 -hsync +vsync
#	xrandr --addmode  DP1 "3840x2160_30.00"
#	xrandr --output eDP1 --auto --primary --output DP1 --mode 3840x2160_30.00
#--above eDP1 --rate 30
#}

govendorcheck() {
	# shellcheck disable=SC2046
	vendorcheck -u ./... | awk '{print $NF}' | sed -e
"s#^github.com/jessfraz/$(basename $(pwd))/##"
}

restart_gpgagent(){
	# Restart the gpg agent.
	# shellcheck disable=SC2046
	kill -9 $(pidof scdaemon) >/dev/null 2>&1
	# shellcheck disable=SC2046
	kill -9 $(pidof gpg-agent) >/dev/null 2>&1
	gpg-connect-agent /bye >/dev/null 2>&1
	gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
}

# Clean Debian packages
apt-clean() {
    sudo apt-get clean
    sudo apt-get autoclean
    sudo apt-get autoremove
}

# Create a new directory and enter it
mkd() {
    mkdir -p "$@" && cd "$@"
#   mkdir -p "$@" && cd "$_";
}

# Print README file
readme() {
    for readme in {readme,README}.{md,MD,markdown,txt,TXT,mkd}; do
        if [[ -f "$readme" ]]; then
            cat "$readme"
        fi
    done
}

# Weather
weather() {
    curl -s "https://wttr.in/${1:-Ponorogo}?m2" | sed -n "1,27p"
}

# Start PHP server
phpserver() {
    local ip=localhost
    local port="${1:-4000}"
    php -S "${ip}:${port}"
}

# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

# find shorthand
function f() {
  find . -name "$1" 2>&1 | grep -v 'Permission denied'
}

# List all files, long format, colorized, permissions in octal
function la() {
   ls -l  "$@" | awk
   "
    {
      k=0;
      for (i=0;i<=8;i++)
        k+=((substr($1,i+2,1)~/[rwx]/) *2^(8-i));
      if (k)
        printf("%0o ",k);
      printf(" %9s  %3s %2s %5s  %6s  %s %s %s\n", $3, $6, $7, $8, $5, $9,$10, $11);
    }"
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# Copy w/ progress
cpy () {
  rsync -WavP --human-readable --progress $1 $2
}

# qfind - used to quickly find files that contain a string in a directory
qfind () {
  find . -exec grep -l -s $1 {} \;
  return 0
}

# get gzipped size
function gz() {
  echo "orig size    (bytes): "
  cat "$1" | wc -c
  echo "gzipped size (bytes): "
  gzip -c "$1" | wc -c
}

# Compare original and gzipped file size
gzs() {
	local origsize
	origsize=$(wc -c < "$1")
	local gzipsize
	gzipsize=$(gzip -c "$1" | wc -c)
	local ratio
	ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
	printf "orig: %d bytes\\n" "$origsize"
	printf "gzip: %d bytes (%2.2f%%)\\n" "$gzipsize" "$ratio"
}

# whois a domain or a URL
function whois() {
  local domain=$(echo "$1" | awk -F/ '{print $3}') # get domain from URL
  if [ -z $domain ] ; then
    domain=$1
  fi
  echo "Getting whois record for: $domain …"

  # avoid recursion
          # this is the best whois server
                          # strip extra fluff
  /usr/bin/whois -h whois.internic.net $domain | sed '/NOTICE:/q'
}

function localip() {
  function _localip() { echo "📶  "$(ipconfig getifaddr "$1"); }
  export -f _localip
  local purple="\x1B\[35m" reset="\x1B\[m"
  networksetup -listallhardwareports | \
    sed -r "s/Hardware Port: (.*)/${purple}\1${reset}/g" | \
    sed -r "s/Device: (en.*)$/_localip \1/e" | \
    sed -r "s/Ethernet Address:/📘 /g" | \
    sed -r "s/(VLAN Configurations)|==*//g"
}

# Extract archives - use: extract <file>
# Based on http://dotfiles.org/~pseup/.bashrc
function extract() {
  if [ -f "$1" ] ; then
    local filename=$(basename "$1")
    local foldername="${filename%%.*}"
    local fullpath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1"`
    local didfolderexist=false
    if [ -d "$foldername" ]; then
      didfolderexist=true
      read -p "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
      echo
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        return
      fi
    fi
    mkdir -p "$foldername" && cd "$foldername"
    case $1 in
      *.tar.bz2) tar xjf "$fullpath" ;;
      *.tar.gz) tar xzf "$fullpath" ;;
      *.tar.xz) tar Jxvf "$fullpath" ;;
      *.tar.Z) tar xzf "$fullpath" ;;
      *.tar) tar xf "$fullpath" ;;
      *.taz) tar xzf "$fullpath" ;;
      *.tb2) tar xjf "$fullpath" ;;
      *.tbz) tar xjf "$fullpath" ;;
      *.tbz2) tar xjf "$fullpath" ;;
      *.tgz) tar xzf "$fullpath" ;;
      *.txz) tar Jxvf "$fullpath" ;;
      *.zip) unzip "$fullpath" ;;
      *) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# my ip on the network
function ip() {
  ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
  echo $ip
}

# use silver-searcher to search for file names (respects .agignore!)
#function agf() {
#  ag $2 -l -g $1
#}
alias agf='ag -l -g'

function killonport() {
  lsof -ti tcp:"$@" -sTCP:LISTEN | xargs kill
}

function o() {
  if [ $# -eq 0 ]; then
    open .;
  else
    open "$@";
  fi;
}

function extract2 () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}


# Normalize `open` across Linux, macOS, and Windows.
# This is needed to make the `o` function (see below) cross-platform.
if [ ! $(uname -s) = 'Darwin' ]; then
	if grep -q Microsoft /proc/version; then
		# Ubuntu on Windows using the Linux subsystem
		alias open='explorer.exe';
	else
		alias open='xdg-open';
	fi
fi

function open() {
  xdg-open $@ & disown
}

# who is using the laptop's iSight camera?
camerausedby () {
  echo "Checking to see who is using the iSight camera… 📷"
  usedby=$(lsof | grep -w "AppleCamera\|USBVDC\|iSight" | awk '{printf $2"\n"}' | xargs ps)
  echo -e "Recent camera uses:\n$usedby"
}

# animated gifs from any video
# from Alex Sexton gist.github.com/SlexAxton/4989674
gifify () {
  if [[ -n "$1" ]]; then
  if [[ $2 == '--good' ]]; then
    ffmpeg -i "$1" -r 10 -vcodec png out-static-%05d.png
    time convert -verbose +dither -layers Optimize -resize 900x900\> out-static*.png  GIF:- | gifsicle --colors 128 --delay=5 --loop --optimize=3 --multifile - > "$1.gif"
    rm out-static*.png
  else
    ffmpeg -i "$1" -s 600x400 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > "$1.gif"
  fi
  else
  echo "proper usage: gifify <input_movie.mov>. You DO need to include extension."
  fi
}

# turn that video into webm.
# ffmpeg --with-libvpx
webmify () {
  ffmpeg -i "$1" -vcodec libvpx -acodec libvorbis -isync -copyts -aq 80 -threads 3 -qmax 30 -y "$2" "$1.webm"
}

# `shellswitch [bash |zsh]`
#   Must be in /etc/shells
shellswitch () {
  chsh -s $(brew --prefix)/bin/$1
}

# Mirror a complete website
function mirror-website() {
  local url=$@
  local domain=`expr "$url" : '^http[s]*://\([^/?]*\)'`
  wget \
    --recursive \
    --no-clobber \
    --page-requisites \
    --html-extension \
    --convert-links \
    --restrict-file-names=windows \
    --domains $domain \
    --no-parent \
    $url
}

# Put my computer to sleep in X minutes
function sleep-in() {
  local minutes=$1
  if [ -z "$minutes" ]; then
    echo "Usage: sleep-in <minutes>"
  else
    local datetime=`date -v+${minutes}M +"%m/%d/%y %H:%M:%S"`
    echo "Scheduling sleep at $datetime"
    sudo pmset schedule sleep "$datetime"
  fi
}

# Maintained by Claud D. Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/

### Miscellaneous {{{
  # Print a message for an information
  function print_info() {
    echo -ne "\033[1;32m"
    echo -n "$@"
    echo -e "\033[m"
  }
  # Print a message for an error
  function print_error() {
    echo -ne "\033[1;31m"
    echo -n "$@"
    echo -e "\033[m"
  }
### }}}
### Essentials {{{
  # Read a set of resources for X applications
Xrdb() {
    if [ -f "${HOME}/.Xresources" -a -x "$(which xrdb)" ]; then
      print_info 'Loading X ressources...'
      xrdb -merge "$HOME/.Xresources" || print_error 'Failed to load X ressources'
    else
      print_error "Can't find ~/.Xresources file or xrdb command."
    fi
  }
  # Modify keymaps and pointer button mappings
Xmodmap() {
    if [ -f "${HOME}/.Xmodmap" -a -x "$(which xmodmap)" ]; then
      print_info "Loading Xmodmap to modify keymaps and pointer button mappings..."
      xmodmap "${HOME}/.Xmodmap" || print_error "Failed to load Xmodmap."
    else
      print_error "Can't load Xmodmap due to missing files."
    fi
  }
Xbindkeys() {
    if [ -f "${HOME}/.xbindkeysrc" -a -x "$(which xbindkeys)" ]; then
      print_info "Launching Xbindkeys to bind commands to certain keys..."
      # LC_ALL=C xbindkeys || print_error "Failed to launch Xbindkeys"
    else
      print_error "Can't find ~/.xbindkeysrc file or xbindkeys command."
    fi
  }
XsetFont() {
    if [ -x "$(which xset)" ]; then
      if [ -x "$(which mkfontdir)" -a -x "$(which mkfontscale)" ]; then
        print_info "Indexing personal fonts"
        mkfontscale "${HOME}/.fonts" 2>/dev/null
        mkfontdir "${HOME}/.fonts"
      else
        print_error "Can't find mkfontdir or mkfontscale command."
      fi
      print_info "Launching Xset to configure personal fonts"
      # Append elements to the current font path
      xset +fp "${HOME}/.fonts"
      # Cause the server to reread the font databases in the current font path
      xset fp rehash
    else
      print_error "Can't find xset command."
    fi
  }

SetXKeyboardMap() {
    # setxkbmap -layout us
    setxkbmap -layout kr -option ctrl:nocaps
  }
  # Set an input method to support multi-languages
  SetIM() {
    if [ -x "$(which ibus-daemon)" ]; then
      # Setup IM enviroment
      print_info "Launching iBus daemon for input method"
      export GTK_IM_MODULE=ibus
      export QT_IM_MODULE=ibus
      export QT4_IM_MODULE=ibus
      export CLUTTER_IM_MODULE=ibus
      export XMODIFIERS=@im=ibus
      ibus-daemon --xim --daemonize || print_error "Failed to launch iBus."
    else
      print_error "There is no iBus IM in the system."
    fi
  }

  # Configure environment variable to enalbe pulse-audio server
PulseAudio() {
    if [[ $(netstat -lnp | grep ':4713') = *LISTEN* ]]; then
      print_info "Configuring PulseAudio server"
      export PULSE_SERVER=localhost:4713
    else
      print_error "There is no PulseAudio in the system."
    fi
  }
  # Launch composite manager to enable more effective window managements
  Compton() {
    if [ -f "${HOME}/.compton.conf" -a -x "$(which compton)" ]; then
      print_info "Launching Compton Composite Manager"
      (sleep 2 && compton --config "${HOME}/.compton.conf" -CGb) || print_error "Failed to launch Compton."
    else
      print_error "Can't find ~/.compton.conf file or compton command."
    fi
  }

### Terminals
  # Run urxvt daemon
  Urxvtd() {
    if [ -x "$(which urxvtd)" ]; then
      print_info "Launching Urxvt daemon..."
      urxvtd --quiet --opendisplay --fork || print_error "Failed to launch Urxvt daemon"
    else
      print_error "Can't find Urxvtd command."
    fi
  }
  # Run urxvt client
  Urxvtc() {
    if [ -x "$(which urxvtc)" ]; then
      print_info "Launching Urxvt Terminal Emulator Client..."
      (urxvtc || print_error "Failed to launch Urxvt") &
    else
      print_error "Can't find Urxvtc command."
    fi
  }
  # Run urxvt
  Urxvt() {
    if [ -x "$(which urxvt)" ]; then
      print_info "Launching Urxvt Terminal Emulator..."
      (urxvt || print_error "Failed to launch Urxvt") &
    else
      print_error "Can't find Urxvt command."
    fi
  }

### Additionals {{{
  WALLPAPER_DIR="${HOME}/.wallpaper/"
  WALLPAPER_RANDOM_TIMER="15m"
  # Set a background image with Feh
  Feh() {
    if [ -x "$(which feh)" ]; then
      print_info "Launching Feh as Wallpaper Manager..."
      while true; do
        (find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.png' \) -print0 |
          shuf -n1 -z | xargs -0 feh --bg-fill) || print_error "Failed to launch Feh"
        sleep $WALLPAPER_RANDOM_TIMER
      done &
    else
      print_error "Can't find feh command."
    fi
  }
  # Change XCursor theme and size
  Xcursor() {
    print_info "Configuring XCursor Theme and Size..."
    export XCURSOR_THEME=Breeze-Obsidian
    export XCURSOR_SIZE=16
    # xsetroot -xcf "${HOME}/.icons/${XCURSOR_THEME}/cursors/left_ptr" "${XCURSOR_SIZE}" &
    # xsetroot -cursor_name left_ptr &
  }
  # Run XAutoLock for managing lock screen
  Xautolock() {
    if [ -x "$(which xautolock)" ]; then
      if [ -x "$(which i3lock)" ]; then
        print_info "Launching XAutoLock with i3lock locker..."
        (xautolock || print_error "Failed to launch xautolock") &
      else
        print_error "Can't find i3lock command."
      fi
    else
      print_error "Can't find xautolock command."
    fi
  }
  Xscreensaver() {
    if [ -x "$(which xscreensaver)" ]; then
      print_info "Launching Xscreensaver..."
      # xscreensaver -nosplash || print_error "Failed to launch Xscreensaver"
    else
      print_error "Can't find xscreensaver command."
    fi
  }
  # Run Albert for desktop launcher
  Albert() {
    if [ -x "$(which albert)" ]; then
      print_info "Launching Albert desktop launcher..."
      ( albert || print_error "Failed to launch Albert") &
    else
      print_error "Can't find albert command."
    fi
  }
  # Run tint2 for a system panel and taskbar
  Tint2() {
    if [ -x "$(which tint2)" ]; then
      print_info "Launching Tint2 Taskbar..."
      ( (sleep 2s && tint2) || print_error "Failed to launch Tint2") &
    else
      print_error "Can't find tint2 command."
    fi
  }
  Pidgin() {
    if [ -x "$(which pidgin)" ]; then
      print_info "Launching Pidgin..."
      # To be update || print_error "Failed to launch urxvt daemon"
    else
      print_error "Can't find pidgin command."
    fi
  }
  # Run Thunar File Manager as daemon
  Thunar() {
    if [ -x "$(which thunar)" ]; then
      print_info "Launching Thunar File Manager as daemon..."
      (thunar --daemon || print_error "Failed to launch Thunar") &
    else
      print_error "Can't find thunar command."
    fi
  }
### }}}


#[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
#Default() {
#  Xrdb
#  Xcursor
#  SetXKeyboardMap
#  # Xmodmap
#  XsetFont
#  Feh
#  SetIM
#  Xautolock
#  PulseAudio
#}


## xsetroot -solid darkgrey
#session=${1:-dwm}

#case $session in
#  awesome)
#    Default
#    Urxvtd
#    Thunar
#    # fix cursors. for a minute :/
#    # xsetroot -cursor_name left_ptr
#    print_info "Loading Awesome Window Manager..."
#    exec awesome
#    ;;
#  dwm)
#    Default
#    Urxvtd
#    Compton
#    Albert
#    # Thunar
#    print_info "Loading DWM Window Manager..."
#    exec ~/.bin/dwm
#    ;;
#  openbox)
#    Default
#    (sleep 2 && compton) &
#    Tint2
#    print_info "Loading OpenBox Window Manager..."
#    exec openbox-session
#    ;;
#  gnome)
#    print_info "Loading GNOME Window Manager..."
#    exec gnome-session
#    ;;
#  xfce4)
#    print_info "Loading XFCE4 Window Manager..."
#    exec xfce4-session
#    ;;
#  *)
#    print_error "None of the valid WM has been selected, Aborting..."
#    exit 1
#    ;;
#esac

####------the new one starts


#!/usr/bin/env bash

# -------------------------------------------------------------------
# err: error message along with a status information
#
# example:
#
# if ! do_something; then
#   err "Unable to do_something"
#   exit "${E_DID_NOTHING}"
# fi
#
err()
{
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

# -------------------------------------------------------------------
# cd: this will overwrite the default "cd"-command
cd()
{
  if [[ "x$*" == "x..." ]]; then
    cd ../..
  elif [[ "x$*" == "x...." ]]; then
    cd ../../..
  elif [[ "x$*" == "x....." ]]; then
    cd ../../../..
  elif [[ "x$*" == "x......" ]]; then
    cd ../../../../..
  elif [ -d ~/.autoenv ]; then
    source ~/.autoenv/activate.sh
    autoenv_cd "$@"
  else
    builtin cd "$@"
  fi
}

# -------------------------------------------------------------------
# cdo: cd into the previous (old) working directory
cdo()
{
  cd $OLDPWD
}

# -------------------------------------------------------------------
# lc: Convert the parameters or STDIN to lowercase.
lc()
{
  if [ $# -eq 0 ]; then
    python -c 'import sys; print sys.stdin.read().decode("utf-8").lower()'
  else
    for i in "$@"; do
        echo $i | python -c 'import sys; print sys.stdin.read().decode("utf-8").lower()'
    done
  fi
}

# -------------------------------------------------------------------
# uc: Convert the parameters or STDIN to uppercase.
uc()
{
  if [ $# -eq 0 ]; then
    python -c 'import sys; print sys.stdin.read().decode("utf-8").upper()'
  else
    for i in "$@"; do
        echo $i | python -c 'import sys; print sys.stdin.read().decode("utf-8").upper()'
    done
  fi
}

# -------------------------------------------------------------------
# Call from a local repo to open the repository on github/bitbucket in browser
#
# usage:
repo()
{
  local giturl=$(git config --get remote.origin.url \
    | sed 's/git@/\/\//g' \
    | sed 's/.git$//' \
    | sed 's/https://g' \
    | sed 's/:/\//g')

  if [[ $giturl == "" ]]; then
    echo "Not a git repository or no remote.origin.url is set."
  else
    local gitbranch=$(git rev-parse --abbrev-ref HEAD)
    local giturl="https:${giturl}"

    if [[ $gitbranch != "master" ]]; then
      if echo "${giturl}" | grep -i "bitbucket" > /dev/null ; then
        local giturl="${giturl}/branch/${gitbranch}"
      else
        local giturl="${giturl}/tree/${gitbranch}"
      fi
    fi

    echo $giturl
    o $giturl
  fi
}

# -------------------------------------------------------------------
# wtfis: Show what a given command really is. It is a combination of "type", "file"
# and "ls". Unlike "which", it does not only take $PATH into account. This
# means it works for aliases and hashes, too. (The name "whatis" was taken,
# and I did not want to overwrite "which", hence "wtfis".)
# The return value is the result of "type" for the last command specified.
#
# usage:
#
#   wtfis man
#   wtfis vi
#
# source: https://raw.githubusercontent.com/janmoesen/tilde/master/.bash/commands
wtfis()
{
  local cmd=""
  local type_tmp=""
  local type_command=""
  local i=1
  local ret=0

  if [ -n "$BASH_VERSION" ]; then
    type_command="type -p"
  else
    type_command=( whence -p ) # changes variable type as well
  fi

  if [ $# -eq 0 ]; then
    # Use "fc" to get the last command, and use that when no command
    # was given as a parameter to "wtfis".
    set -- $(fc -nl -1)

    while [ $# -gt 0 -a '(' "sudo" = "$1" -o "-" = "${1:0:1}" ')' ]; do
      # Ignore "sudo" and options ("-x" or "--bla").
      shift
    done

    # Replace the positional parameter array with the last command name.
    set -- "$1"
  fi

  for cmd; do
    type_tmp="$(type "$cmd")"
    ret=$?

    if [ $ret -eq 0 ]; then
      # Try to get the physical path. This works for hashes and
      # "normal" binaries.
      local path_tmp=$(${type_command} "$cmd" 2>/dev/null)

      if [ $? -ne 0 ] || ! test -x "$path_tmp"; then
        # Show the output from "type" without ANSI escapes.
        echo "${type_tmp//$'\e'/\\033}"

        case "$(command -v "$cmd")" in
          'alias')
            local alias_="$(alias "$cmd")"

            # The output looks like "alias foo='bar'" so
            # strip everything except the body.
            alias_="${alias_#*\'}"
            alias_="${alias_%\'}"

            # Use "read" to process escapes. E.g. 'test\ it'
            # will # be read as 'test it'. This allows for
            # spaces inside command names.
            read -d ' ' alias_ <<< "$alias_"

            # Recurse and indent the output.
            # TODO: prevent infinite recursion
            wtfis "$alias_" 2>&2 | sed 's/^/  /'

            ;;
          'keyword' | 'builtin')

            # Get the one-line description from the built-in
            # help, if available. Note that this does not
            # guarantee anything useful, though. Look at the
            # output for "help set", for instance.
            help "$cmd" 2>/dev/null | {
              local buf line
              read -r line
              while read -r line; do
                buf="$buf${line/.  */.} "
                if [[ "$buf" =~ \.\ $ ]]; then
                  echo "$buf"
                  break
                fi
              done
            }

            ;;
        esac
      else
        # For physical paths, get some more info.
        # First, get the one-line description from the man page.
        # ("col -b" gets rid of the backspaces used by OS X's man
        # to get a "bold" font.)
        (COLUMNS=10000 man "$(basename "$path_tmp")" 2>/dev/null) | col -b | \
        awk '/^NAME$/,/^$/' | {
          local buf=""
          local line=""

          read -r line
          while read -r line; do
            buf="$buf${line/.  */.} "
            if [[ "$buf" =~ \.\ $ ]]; then
              echo "$buf"
              buf=''
              break
            fi
          done

          [ -n "$buf" ] && echo "$buf"
        }

        # Get the absolute path for the binary.
        local full_path_tmp="$(
          cd "$(dirname "$path_tmp")" \
            && echo "$PWD/$(basename "$path_tmp")" \
            || echo "$path_tmp"
        )"

        # Then, combine the output of "type" and "file".
        local fileinfo="$(file "$full_path_tmp")"
        echo "${type_tmp%$path_tmp}${fileinfo}"

        # Finally, show it using "ls" and highlight the path.
        # If the path is a symlink, keep going until we find the
        # final destination. (This assumes there are no circular
        # references.)
        local paths_tmp=("$path_tmp")
        local target_path_tmp="$path_tmp"

        while [ -L "$target_path_tmp" ]; do
          target_path_tmp="$(readlink "$target_path_tmp")"
          paths_tmp+=("$(
            # Do some relative path resolving for systems
            # without readlink --canonicalize.
            cd "$(dirname "$path_tmp")"
            cd "$(dirname "$target_path_tmp")"
            echo "$PWD/$(basename "$target_path_tmp")"
          )")
        done

        local ls="$(command ls -fdalF "${paths_tmp[@]}")"
        echo "${ls/$path_tmp/$'\e[7m'${path_tmp}$'\e[27m'}"
      fi
    fi

    # Separate the output for all but the last command with blank lines.
    [ $i -lt $# ] && echo
    let i++
  done

  return $ret
}

# -------------------------------------------------------------------
# whenis: Try to make sense of the date. It supports everything GNU date knows how to
# parse, as well as UNIX timestamps. It formats the given date using the
# default GNU date format, which you can override using "--format='%x %y %z'.
#
# usage:
#
#   $ whenis 1234567890            # UNIX timestamps
#   Sat Feb 14 00:31:30 CET 2009
#
#   $ whenis +1 year -3 months     # relative dates
#   Fri Jul 20 21:51:27 CEST 2012
#
#   $ whenis 2011-10-09 08:07:06   # MySQL DATETIME strings
#   Sun Oct  9 08:07:06 CEST 2011
#
#   $ whenis 1979-10-14T12:00:00.001-04:00 # HTML5 global date and time
#   Sun Oct 14 17:00:00 CET 1979
#
#   $ TZ=America/Vancouver whenis # Current time in Vancouver
#   Thu Oct 20 13:04:20 PDT 2011
#
# For more info, check out http://kak.be/gnudateformats.
whenis()
{
  # Default GNU date format as seen in date.c from GNU coreutils.
  local format='%a %b %e %H:%M:%S %Z %Y'
  if [[ "$1" =~ ^--format= ]]; then
    format="${1#--format=}"
    shift
  fi

  # Concatenate all arguments as one string specifying the date.
  local date="$*"
  if [[ "$date"  =~ ^[[:space:]]*$ ]]; then
    date='now'
  elif [[ "$date"  =~ ^[0-9]{13}$ ]]; then
    # Cut the microseconds part.
    date="${date:0:10}"
  fi

  # Use GNU date in all other situations.
  [[ "$date" =~ ^[0-9]+$ ]] && date="@$date"
  date -d "$date" +"$format"
}

# -------------------------------------------------------------------
# box: a function to create a box of '=' characters around a given string
#
# usage: box 'testing'
box()
{
  local t="$1xxxx"
  local c=${2:-"#"}

  echo ${t//?/$c}
  echo "$c $1 $c"
  echo ${t//?/$c}
}

# -------------------------------------------------------------------
# htmlEntityToUTF8: convert html-entity to UTF-8
htmlEntityToUTF8()
{
  if [ $# -eq 0 ]; then
    echo "Usage: htmlEntityToUTF8 \"&#9661;\""
    return 1
  else
    echo $1 | recode html..UTF8
  fi
}

# -------------------------------------------------------------------
# UTF8toHtmlEntity: convert UTF-8 to html-entity
UTF8toHtmlEntity()
{
  if [ $# -eq 0 ]; then
    echo "Usage: UTF8toHtmlEntity \"♥\""
    return 1
  else
    echo $1 | recode UTF8..html
  fi
}

# -------------------------------------------------------------------
# optiImages: optimized images (png/jpg) in the current dir + sub-dirs
#
# INFO: use "grunt-contrib-imagemin" for websites!
optiImages()
{
  find . -iname '*.png' -exec optipng -o7 {} \;
  find . -iname '*.jpg' -exec jpegoptim --force {} \;
}

# -------------------------------------------------------------------
# Get colors in manual pages

# -------------------------------------------------------------------
# lman: Open the manual page for the last command you executed.
lman()
{
  local cmd

  set -- $(fc -nl -1)
  while [ $# -gt 0 -a '(' "sudo" = "$1" -o "-" = "${1:0:1}" ')' ]; do
    shift
  done

  cmd="$(basename "$1")"
  man "$cmd" || help "$cmd"
}

# -------------------------------------------------------------------
# testConnection: check if connection to google.com is possible
#
# usage:
#   testConnection 1  # will echo 1 || 0
#   testConnection    # will return 1 || 0
testConnection()
{
  local tmpReturn=1
  $(wget --tries=2 --timeout=2 www.google.com -qO- &>/dev/null 2>&1)

  if [ $? -eq 0 ]; then
    tmpReturn=0
  else
    tmpReturn=1
  fi

  if [ "$1" ] && [ $1 -eq 1 ]; then
    echo $tmpReturn
  else
    return $tmpReturn
  fi
}

# -------------------------------------------------------------------
# netstat_used_local_ports: get used tcp-ports
netstat_used_local_ports()
{
  netstat -atn \
    | awk '{printf "%s\n", $4}' \
    | grep -oE '[0-9]*$' \
    | sort -n \
    | uniq
}

# -------------------------------------------------------------------
# netstat_free_local_port: get one free tcp-port
netstat_free_local_port()
{
  # didn't work with zsh / bash is ok
  #read lowerPort upperPort < /proc/sys/net/ipv4/ip_local_port_range

  for port in $(seq 32768 61000); do
    for i in $(netstat_used_local_ports); do
      if [[ $used_port -eq $port ]]; then
        continue
      else
        echo $port
        return 0
      fi
    done
  done

  return 1
}

# -------------------------------------------------------------------
# connection_overview: get stats-overview about your connections
netstat_connection_overview()
{
  netstat -nat \
    | awk '{print $6}' \
    | sort \
    | uniq -c \
    | sort -n
}

# -------------------------------------------------------------------
# nice mount (http://catonmat.net/blog/another-ten-one-liners-from-commandlingfu-explained)
#
# displays mounted drive information in a nicely formatted manner
mount_info()
{
  (echo "DEVICE PATH TYPE FLAGS" && mount | awk '$2="";1') \
    | column -t;
}

# -------------------------------------------------------------------
# sniff: view HTTP traffic
#
# usage: sniff [eth0]
#sniff()
#{
#  if [ $1 ]; then
#    local device=$1
#  else
#    local device='eth0'
#  fi

#  sudo ngrep -d ${device} -t '^(GET|POST) ' 'tcp and port 80'
#}

# -------------------------------------------------------------------
# httpdump: view HTTP traffic
#
# usage: httpdump [eth1]
#httpdump()
#{
#  if [ $1 ]; then
#    local device=$1
#  else
#    local device='eth0'
#  fi

#  sudo tcpdump -i ${device} -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\"
#}

# -------------------------------------------------------------------
# iptablesBlockIP: block a IP via "iptables"
#
# usage: iptablesBlockIP 8.8.8.8
iptablesBlockIP()
{
  if [ $# -eq 0 ]; then
    echo "Usage: iptablesBlockIP 123.123.123.123"
    return 1
  else
    sudo iptables -A INPUT -s $1 -j DROP
  fi
}

# -------------------------------------------------------------------
# ips: get the local IP's
ips()
{
  ifconfig | grep "inet " | awk '{ print $2 }' | cut -d ":" -f 2
}

# -------------------------------------------------------------------
# cleanTheSystem: purge old config, kernel, trash etc. from Ubuntu / Debian
#
# WARNING: take a look on what the package-manager will do
cleanTheSystem()
{
  local OLDCONF=$(dpkg -l | grep "^rc" | awk '{print $2}')
  local CURKERNEL=$(uname -r | sed 's/-*[a-z]//g' | sed 's/-386//g' | sed 's/-164//g')
  local LINUXPKG="linux-(image|headers|ubuntu-modules|restricted-modules)"
  local METALINUXPKG="linux-(image|headers|restricted-modules)-(generic|i386|amd64|server|common|rt|xen)"
  local OLDKERNELS=$(dpkg -l | awk '{print $2}' | command grep -E $LINUXPKG | grep -vE $METALINUXPKG | grep -v $CURKERNEL)

  echo -e $COLOR_YELLOW"clear ".deb"-cache ..."$COLOR_NO_COLOR
  sudo aptitude autoclean

  echo -e $COLOR_RED"remove not needed packages ..."$COLOR_NO_COLOR
  sudo apt-get autoremove

  echo -e $COLOR_YELLOW"remove old config-files..."$COLOR_NO_COLOUR
  sudo aptitude purge $OLDCONF

  echo -e $COLOR_YELLOW"remove old kernels ..."$COLOR_NO_COLOUR
  sudo aptitude purge $OLDKERNELS

  echo -e $COLOR_YELLOW"clean trash ..."$COLOR_NO_COLOUR
  sudo rm -rf /home/*/.local/share/Trash/*/** &> /dev/null
  sudo rm -rf /root/.local/share/Trash/*/** &> /dev/null

  echo -e $COLOR_YELLOW"... everything is clean!!!"$COLOR_NO_COLOUR
}

# -------------------------------------------------------------------
# extract: extract of compressed-files
extract()
{
  if [ -f $1 ] ; then
    local lower=$(lc $1)

    case $lower in
      *.tar.bz2)   tar xvjf $1     ;;
      *.tar.gz)    tar xvzf $1     ;;
      *.bz2)       bunzip2 $1      ;;
      *.rar)       unrar e $1      ;;
      *.gz)        gunzip $1       ;;
      *.tar)       tar xvf $1      ;;
      *.tbz2)      tar xvjf $1     ;;
      *.tgz)       tar xvzf $1     ;;
      *.lha)       lha e $1        ;;
      *.zip)       unzip $1        ;;
      *.Z)         uncompress $1   ;;
      *.7z)        7z x $1         ;;
      *)           echo "'$1' cannot be extracted via >extract<"
                   return 1        ;;
    esac

  else
    echo "'$1' is not a valid file"
  fi
}

# -------------------------------------------------------------------
# os-info: show some info about your system
os-info()
{
  lsb_release -a
  uname -a

  if [ -z /etc/lsb-release ]; then
    cat /etc/lsb-release;
  fi;

  if [ -z /etc/issue ]; then
    cat /etc/issue;
  fi;

  if [ -z /proc/version ]; then
    cat /proc/version;
  fi;
}

# -------------------------------------------------------------------
# command_exists: check if a command exists
command_exists()
{
    return type "$1" &> /dev/null ;
}

# -------------------------------------------------------------------
# stripspace: strip unnecessary whitespace from file
stripspace()
{
  if [ $# -eq 0 ]; then
    echo "Usage: stripspace FILE"
    exit 1
  else
    local tempfile=mktemp
    git stripspace < "$1" > tempfile
    mv tempfile "$1"
  fi
}

# -------------------------------------------------------------------
# battery_life : Echo the percentage of battery life remaining
battery_life()
{
  local life=$(acpi -b | cut -d "," -f 2)
  # NOTE: the trailing % is stripped
  echo ${life%\%}
}

# -------------------------------------------------------------------
# battery_indicator: echo a indicator for your battery-time
battery_indicator()
{
  local num=$(battery_life)

  if [ $num -gt 95 ]; then
    # 95-100% remaining : GREEN
    echo -e "${COLOR_GREEN}♥♥♥♥♥♥${COLOR_NO_COLOUR}"
  elif [ $num -gt 85 ]; then
    # 85-95% remaining : GREEN
    echo -e "${COLOR_GREEN}♥♥♥♥♥♡${COLOR_NO_COLOUR}"
  elif [ $num -gt 65 ]; then
    # 65-85% remaining : GREEN
    echo -e "${COLOR_GREEN}♥♥♥♥♡♡${COLOR_NO_COLOUR}"
  elif [ $num -gt 45 ]; then
    # 45-65% remaining : GREEN
    echo -e "${COLOR_GREEN}♥♥♥♡♡♡${COLOR_NO_COLOUR}"
  elif [ $num -gt 25 ]; then
    # 25-45% remaining : GREEN
    echo -e "${COLOR_GREEN}♥♥♡♡♡♡${COLOR_NO_COLOUR}"
  elif [ $num -gt 10 ]; then
    # 11-25% remaining : YELLOW
    echo -e "${COLOR_YELLOW}♥♡♡♡♡♡${COLOR_NO_COLOUR}"
  else
    # 0-10% remaining : RED
    echo -e "${COLOR_RED}♥♡♡♡♡♡${COLOR_NO_COLOUR}"
  fi
}

# -------------------------------------------------------------------
# logssh: establish ssh connection + write a logfile
logssh()
{
  ssh $1 | tee sshlog
}

# -------------------------------------------------------------------
# givedef: shell function to define words
# http://vikros.tumblr.com/post/23750050330/cute-little-function-time
givedef()
{
  if [ $# -ge 2 ]; then
    echo "givedef: too many arguments" >&2
    return 1
  else
    curl --silent "dict://dict.org/d:$1"
  fi
}

# -------------------------------------------------------------------
# lsssh: pretty print all established SSH connections
lsssh ()
{
  local ip=""
  local domain=""
  local conn=""

  lsof -i4 -s TCP:ESTABLISHED -n | grep '^ssh' | while read conn; do
    ip=$(echo $conn | grep -oE '\->[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[^ ]+')
    ip=${ip/->/}
    domain=$(dig -x ${ip%:*} +short)
    domain=${domain%.}
    # display nonstandard port if relevant
    printf "%s (%s)\n" $domain  ${ip/:ssh}
  done | column -t
}

# -------------------------------------------------------------------
# WARNING -> replace: changes multiple files at once
replace()
{
  if [ $3 ]; then
    find $1 -type f -exec sed -i 's/$2/$3/g' {} \;
  else
    echo "Missing argument"
    exit 1
  fi
}

# -------------------------------------------------------------------
# calc: Simple calculator
# usage: e.g.: 3+3 || 6*6/2
calc()
{
  local result=""
  result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')"
  #                       └─ default (when `--mathlib` is used) is 20
  #
  if [[ "$result" == *.* ]]; then
    # improve the output for decimal numbers
    printf "$result" |
    sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
        -e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
        -e 's/0*$//;s/\.$//'   # remove trailing zeros
  else
    printf "$result"
  fi
  printf "\n"
}

# -------------------------------------------------------------------
# mkd: Create a new directory and enter it
mkd()
{
  mkdir -p "$@" && cd "$_"
}

# -------------------------------------------------------------------
# mkf: Create a new directory, enter it and create a file
#
# usage: mkf /tmp/lall/foo.txt
mkf()
{
  mkd $(dirname "$@") && touch $@
}

# -------------------------------------------------------------------
# rand_int: use "urandom" to get random int values
#
# usage: rand_int 8 --> e.g.: 32245321
rand_int()
{
  if [ $1 ]; then
    local length=$1
  else
    local length=16
  fi

  tr -dc 0-9 < /dev/urandom  | head -c${1:-${length}}
}

# -------------------------------------------------------------------
# passwdgen: a password generator
#
# usage: passwdgen 8 --> e.g.: f4lwka_2f
passwdgen()
{
  if [ $1 ]; then
    local length=$1
  else
    local length=16
  fi

  tr -dc A-Za-z0-9_ < /dev/urandom  | head -c${1:-${length}}
}

# -------------------------------------------------------------------
# targz: Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
targz()
{
  local tmpFile="${@%/}.tar";
  tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

  local size=$(
    stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
    stat -c"%s" "${tmpFile}" 2> /dev/null;  # GNU `stat`
  );

  local cmd="";
  if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
    # the .tar file is smaller than 50 MB and Zopfli is available; use it
    cmd="zopfli";
  else
    if hash pigz 2> /dev/null; then
      cmd="pigz";
    else
      cmd="gzip";
    fi;
  fi;

  echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
  "${cmd}" -v "${tmpFile}" || return 1;
  [ -f "${tmpFile}" ] && rm "${tmpFile}";

  local zippedSize=$(
  	stat -f"%z" "${tmpFile}.gz" 2> /dev/null; # OS X `stat`
  	stat -c"%s" "${tmpFile}.gz" 2> /dev/null; # GNU `stat`
  );

  echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}

# -------------------------------------------------------------------
# duh: Sort the "du"-command output and use human-readable units.
duh()
{
  local unit=""
  local size=""

  du -k "$@" | sort -n | while read size fname; do
    for unit in KiB MiB GiB TiB PiB EiB ZiB YiB; do
      if [ "$size" -lt 1024 ]; then
        echo -e "${size} ${unit}\t${fname}"
        break
      fi
      size=$((size/1024))
    done
  done
}

# -------------------------------------------------------------------
# fs: Determine size of a file or total size of a directory
fs()
{
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh
  else
    local arg=-sh
  fi

  if [[ -n "$@" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* ./*
  fi
}

# -------------------------------------------------------------------
# ff: displays all files in the current directory (recursively)
#ff()
#{
#  find . -type f -iname '*'$*'*' -ls
#}

# -------------------------------------------------------------------
# fstr: find text in files
fstr()
{
  OPTIND=1
  local case=""
  local usage="fstr: find string in files.
  Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "

  while getopts :it opt
  do
        case "$opt" in
        i) case="-i " ;;
        *) echo "$usage"; return;;
        esac
  done

  shift $(( $OPTIND - 1 ))
  if [ "$#" -lt 1 ]; then
    echo "$usage"
    return 1
  fi

  find . -type f -name "${2:-*}" -print0 \
    | xargs -0 egrep --color=auto -Hsn ${case} "$1" 2>&- \
    | more
}

# -------------------------------------------------------------------
# file_backup_compressed: create a compressed backup (with date)
# in the current dir
#
# usage: file_backup_compressed test.txt
file_backup_compressed()
{
  if [ $1 ]; then
    if [ -z $1 ]; then
      echo "$1: not found"
      return 1
    fi

    tar czvf "./$(basename $1)-$(date +%y%m%d-%H%M%S).tar.gz" "$1"
  else
    echo "Missing argument"
    return 1
  fi
}

# -------------------------------------------------------------------
# file_backup: creating a backup of a file (with date)
file_backup()
{
  for FILE ; do
    [[ -e "$1" ]] && cp "$1" "${1}_$(date +%Y-%m-%d_%H-%M-%S)" || echo "\"$1\" not found." >&2
  done
}

# -------------------------------------------------------------------
# file_information: output information to a file
file_information()
{
  if [ $1 ]; then
    if [ -z $1 ]; then
      echo "$1: not found"
      return 1
    fi

    echo $1
    ls -l $1
    file $1
    ldd $1
  else
    echo "Missing argument"
    return 1
  fi
}

# -------------------------------------------------------------------
# dataurl: create a data URL from a file
dataurl()
{
  local mimeType=$(file -b --mime-type "$1")

  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi

  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# -------------------------------------------------------------------
# gitio: create a git.io short URL
gitio()
{
  if [ -z "${1}" ]; then
    echo "Usage: \`gitio github-url-or-shortcut\`"
    return 1
  fi

  local url
  local code

  if [[ "$1" =~ "https:" ]]; then
    url=$1
  else
    url="https://github.com/${1}"
  fi

  code=$(curl_post -k https://git.io/create -F "url=${url}")

  echo https://git.io/${code}
}

# -------------------------------------------------------------------
# shorturl: Create a short URL
shorturl()
{
  if [ -z "${1}" ]; then
    echo "Usage: \`shorturl url\`"
    return 1
  fi

  curl -s https://www.googleapis.com/urlshortener/v1/url \
    -H 'Content-Type: application/json' \
    -d '{"longUrl": '\"$1\"'}' | grep id | cut -d '"' -f 4
}

# -------------------------------------------------------------------
# server: Start an HTTP server from a directory, optionally specifying the port
server()
{
  local free_port=$(netstat_free_local_port)
  local port="${1:-${free_port}}"

  sleep 1 && o "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# -------------------------------------------------------------------
# phpserver: Start a PHP server from a directory, optionally specifying 2x $_ENV and ip:port
# (Requires PHP 5.4.0+.)
#
# usage:
# phpserver [port=auto] [ip=127.0.0.1] [FOO_1=BAR_1] [FOO_2=BAR_2]
phpserver()
{
  local free_port=$(netstat_free_local_port)
  local port="${1:-${free_port}}"
  local ip="${2:-127.0.0.1}"

  if [ $3 ] && [ $4 ]; then
    export ${3}=${4}
  fi

  if [ $5 ] && [ $6 ]; then
    export ${5}=${6}
  fi

  sleep 1 && o "http://${ip}:${port}/" &
  php -d variables_order=EGPCS -S ${ip}:${port}
}

# php-parse-error-check: check for parse errors
#
# usage: php-parse-error-check /var/www/web3/
php-parse-error-check()
{
  if [ $1 ]; then
    local location=$1
  else
    local location="."
  fi

  find ${location} -name "*.php" -exec php -l {} \; | grep "Parse error"
}

# -------------------------------------------------------------------
# psgrep: grep a process
psgrep()
{
  if [ ! -z $1 ] ; then
    echo "Grepping for processes matching $1..."
    ps aux | grep -i $1 | grep -v grep
  else
    echo "!! Need a process-name to grep for"
    return 1
  fi
}

# -------------------------------------------------------------------
# cpuinfo: get info about your cpu
cpuinfo()
{
  if lscpu > /dev/null 2>&1; then
    lscpu
  else
    cat /proc/cpuinfo
  fi
}

# -------------------------------------------------------------------
# gz: Compare original and gzipped file size
#
# usage: gz /path/to/file.html
gz()
{
  local origsize=$(wc -c < "$1")
  local gzipsize=$(gzip -c "$1" | wc -c)
  local ratio=$(echo "$gzipsize * 100/ $origsize" | bc -l)

  printf "orig: %d bytes\n" "$origsize"
  printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# -------------------------------------------------------------------
# json: Syntax-highlight JSON strings or files
#
# usage: json '{"foo":42}'` or `echo '{"foo":42}' | json
json()
{
  if [ -t 0 ]; then # argument
    python -mjson.tool <<< "$*" | pygmentize -l javascript
  else # pipe
    python -mjson.tool | pygmentize -l javascript
  fi
}

# -------------------------------------------------------------------
# escape: Escape UTF-8 characters into their 3-byte format
escape()
{
  printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
  # print a newline unless we’re piping the output to another program
  if [ -t 1 ]; then
    echo # newline
  fi
}

# -------------------------------------------------------------------
# unidecode: Decode \x{ABCD}-style Unicode escape sequences
unidecode()
{
  perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
  # print a newline unless we’re piping the output to another program
  if [ -t 1 ]; then
    echo # newline
  fi
}

# -------------------------------------------------------------------
# codepoint: Get a character’s Unicode code point
codepoint()
{
  perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))"
  # print a newline unless we’re piping the output to another program
  if [ -t 1 ]; then
    echo # newline
  fi
}

# -------------------------------------------------------------------
# history_top_used: show your most used commands in your history
history_top_used()
{
  history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# -------------------------------------------------------------------
# getcertnames: Show all the names (CNs and SANs) listed in the
#               SSL certificate for a given domain.
#
# usage: getcertnames moelleken.org
getcertnames()
{
  if [ -z "${1}" ]; then
    echo "ERROR: No domain specified.";
    return 1;
  fi;

  local domain="${1}";
  local newline="";

  echo "Testing ${domain}…";
  echo $newline;

  local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
    | openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

  if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
    local certText=$(echo "${tmp}" \
      | openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
      no_serial, no_sigdump, no_signame, no_validity, no_version");
    echo "Common Name:";
    echo $newline;
    echo "${certText}" \
      | grep "Subject:" \
      | sed -e "s/^.*CN=//" \
      | sed -e "s/\/emailAddress=.*//";
    echo $newline;
    echo "Subject Alternative Name(s):";
    echo $newline;
    echo "${certText}" \
      | grep -A 1 "Subject Alternative Name:" \
      | sed -e "2s/DNS://g" -e "s/ //g" \
      | tr "," "\n" \
      | tail -n +2;
    return 0;
  else
    echo "ERROR: Certificate not found.";
    return 1;
  fi;
}

# -------------------------------------------------------------------
# note: add a note to the ~/notes.txt file
#
# usage:  note 'title' 'body'
#         echo 'body' | note
note()
{
  local title
  local body

  if [ -t 0 ]; then
    title="$1"
    body="$2"
  else
    title=$(cat)
  fi

  echo "Title: ${title} Body: ${body}" >> ~/notes.txt
}

# -------------------------------------------------------------------
# note_show: show your notes
note_show()
{
  while read line; do
    echo $line
  done < ~/notes.txt
}

# -------------------------------------------------------------------
# print_all_colors: show all printable colors in the shell
print_all_colors()
{
  # credit to http://askubuntu.com/a/279014
  for x in 0 1 4 5 7 8; do
    for i in `seq 30 37`; do
      for a in `seq 40 47`; do
        echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
      done
      echo ""
    done
  done
  echo ""
}

# -------------------------------------------------------------------
# tail with search highlight
#
# usage: t /var/log/Xorg.0.log [kHz]
t()
{
  if [ $# -eq 0 ]; then
    echo "Usage: t /var/log/Xorg.0.log [kHz]"
    return 1
  else
    if [ $2 ]; then
      tail -n 50 -f $1 | perl -pe "s/$2/${COLOR_LIGHT_RED}$&${COLOR_NO_COLOUR}/g"
    else
      tail -n 50 -f $1
    fi
  fi
}

# -------------------------------------------------------------------
# httpDebug: download a web page and show info on what took time
#
# usage: httpDebug http://github.com
httpDebug()
{
  curl $@ -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\n"
}

# -------------------------------------------------------------------
# digga: show dns-settings from a domain e.g. MX, IP
#
# usage: digga moelleken.org
digga()
{
  if [ $# -eq 0 ]; then
    echo "Usage: digga moelleken.org"
    return 1
  else
    dig +nocmd "$1" ANY +multiline +noall +answer
  fi
}

# -------------------------------------------------------------------
# gid: Install Grunt plugins and add them as `devDependencies` to `package.json`
#
# usage: gid contrib-watch contrib-uglify
gid()
{
  npm install --save-dev ${*/#/grunt-}
}

# -------------------------------------------------------------------
# gi: Install Grunt plugins and add them as `dependencies` to `package.json`
#
# usage: gi contrib-watch contrib-uglify
gi()
{
  npm install --save ${*/#/grunt-}
}

# -------------------------------------------------------------------
# `m`: with no arguments opens the current directory in TextMate, otherwise
# opens the given location
m()
{
  if [ $# -eq 0 ]; then
    mate .
  else
    mate "$@"
  fi
}

# -------------------------------------------------------------------
# `s`: with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
s()
{
  if [ $# -eq 0 ]; then
    subl -a .
  else
    subl -a "$@"
  fi
}

# -------------------------------------------------------------------
# `a`: with no arguments opens the current directory in Atom Editor, otherwise
# opens the given location
a()
{
  if [ $# -eq 0 ]; then
    atom .
  else
    atom "$@"
  fi
}

# -------------------------------------------------------------------
# `v`: with no arguments opens the current directory in Vim, otherwise opens the
# given location
v()
{
  if [ $# -eq 0 ]; then
    vim .
  else
    vim "$@"
  fi
}

# -------------------------------------------------------------------
# `o`: with no arguments opens current directory, otherwise opens the given
# location
o()
{
  local open_command=""

  if [[ $SYSTEM_TYPE == "Win10_Linux" ]]; then
    # Windows using the Linux subsystem
    alias open='explorer.exe'
  elif gnome-open --version /dev/null > /dev/null 2>&1; then
    # GNOME
    open_command='gnome-open'
  elif exo-open --version /dev/null > /dev/null 2>&1; then
    # Xfce
    open_command='exo-open'
  elif kde-open --version /dev/null > /dev/null 2>&1; then
    # KDE
    open_command='kde-open'
  elif xdg-open --version /dev/null > /dev/null 2>&1; then
    # Linux
    open_command='xdg-open'
  elif open --version /dev/null > /dev/null 2>&1; then
    # Mac OS
    open_command='open'
  elif cygstart --version /dev/null > /dev/null 2>&1; then
    # Windows using Cygwin
    open_command='cygstart'
  elif [[ $SYSTEM_TYPE == "MINGW" ]]; then
    # Windows using MinGW
    open_command='start ""'
  fi

  if [ $# -eq 0 ]; then
    open_command_path="."
  else
    open_command_path="$@"
  fi

  # don't use nohup on OSX
  if [[ "$SYSTEM_TYPE" == "OSX" ]]; then
    $open_command "$open_command_path" &>/dev/null
  else
    nohup $open_command "$open_command_path" &>/dev/null
  fi
}

# -------------------------------------------------------------------
# `tre`: is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tre()
{
  tree -haC -I '.git|node_modules|bower_components|.Spotlight-V100|.TemporaryItems|.DocumentRevisions-V100|.fseventsd' --dirsfirst "$@" | less -FRNX;
}

#-------------------------------------------------------------------
#`sshkey`: is a function to copy the ssh key into the clipboard
# options:
#   x: for xclip selection clipboard
sshkey()
{
  if [ -f "$HOME/.ssh/id_rsa" ]; then
    #default use xclip and selection clipboard
    if ( [ $# -eq 0 ] || [ "$1" == "x" ] ) && [ -x /usr/bin/xclip ]; then
      cat ~/.ssh/id_rsa.pub | /usr/bin/xclip -selection "clipboard" && echo "Copied to clipboard"
    fi
    #add here other clipboards
  else
    echo "No ssh key found"
    return 1
  fi
}

# -------------------------------------------------------------------
# pidenv: show PID environment in human-readable form
#
# https://github.com/darkk/home/blob/master/bin/pidenv
pidenv()
{
  local multipid=false
  local pid=""

  if [ $# = 0 ]; then
    echo "Usage: $0: pid [pid] [pid]..."
    return 0
  fi

  if [ $# -gt 1 ]; then
    multipid=true
  fi

  while [ $# != 0 ]; do
    pid=$1
    shift

    if [ -d "/proc/$pid" ]; then
      if $multipid; then
        sed "s,\x00,\n,g" < /proc/$pid/environ | sed "s,^,$pid:,"
      else
        sed "s,\x00,\n,g" < /proc/$pid/environ
      fi
    else
      echo "$0: $pid is not a pid" 1>&2
    fi
  done
}

# -------------------------------------------------------------------
# process: show process-name environment in human-readable form
processenv()
{
  if [ $# = 0 ]; then
    echo "Usage: $0: process-name"
    return 0
  fi

  pidenv $(pidof $1)
}

# -------------------------------------------------------------------
# shellShockCheck: http://www.openwall.com/lists/oss-security/2014/09/24/11
shellShockCheck()
{
  env x='() { :;}; echo vulnerable' bash -c "echo if you see vulnerable, then you need a update";
}

# -------------------------------------------------------------------
# callback for bash-git-prompt
prompt_callback()
{
  if [[ $SYSTEM_TYPE == "CYGWIN" || $SYSTEM_TYPE == "MINGW" ]]; then
    if [[ $(git config --get core.autocrlf) != "true" ]]; then
      s=" CRLF";
    fi
    if [[ $(git config --get core.filemode) != "false" ]]; then
      s+=" FILEMODE";
    fi
    if [[ -n $s ]]; then
      echo "\[${COLOR_RED}\]${s}\[${COLOR_NO_COLOUR}\]";
    fi
  fi
}

# -------------------------------------------------------------------
# git_prompt for PS1
#__git_prompt()
#{
#  local s=''
#  local branchName=''
#
#  # Check if the current directory is in a Git repository.
#  if [[ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == "0" ]]; then
#
#    # The following is to too slow on cygwin/mingw. especially for large repositoryies.
#    if [[ $SYSTEM_TYPE != "CYGWIN" && $SYSTEM_TYPE != "MINGW" ]]; then
#      # Check if the current directory is in .git before running git checks.
#      if [[ "$(git rev-parse --is-inside-git-dir 2>/dev/null)" == "false" ]]; then
#
#        # Create a copy of the index to avoid conflicts with parallel git commands, e.g. git rebase.
#        __GIT_INDEX_FILE_ORIG="$GIT_INDEX_FILE"
#        __GIT_DIR="$(git rev-parse --git-dir)"
#        if [[ -z "$GIT_INDEX_FILE" ]]; then
#          __GIT_INDEX_FILE="$__GIT_DIR/index"
#        else
#          __GIT_INDEX_FILE="$GIT_INDEX_FILE"
#        fi
#        __GIT_INDEX_PROMPT="/tmp/git-index-prompt$$"
#        cp "$__GIT_INDEX_FILE" $__GIT_INDEX_PROMPT 2>/dev/null
#        export GIT_INDEX_FILE="$__GIT_INDEX_PROMPT"
#
#        # Ensure the copied index is up to date.
#        git update-index --really-refresh -q &> /dev/null;
#        # Check if we are ahead or behind our tracking branch (https://gist.github.com/HowlingMind/996093).
#        local git_status="$(LANG=C LANGUAGE=C git status 2>/dev/null)";
#
#        local remote_pattern="Your branch is (ahead|behind).*by ([[:digit:]]*) commit"
#
#        if [ -n "$BASH_VERSION" ]; then
#
#          if [[ "$git_status" =~ $remote_pattern ]]; then
#            if [[ "${BASH_REMATCH[1]}" == "ahead" ]]; then
#              s+="${ICON_FOR_UP}${BASH_REMATCH[2]} "
#            else
#              s+="${ICON_FOR_DOWN}${BASH_REMATCH[2]} "
#            fi
#          fi
#
#        elif [ -n "$ZSH_VERSION" ]; then
#
#          if [[ "$git_status" =~ $remote_pattern ]]; then
#            if [[ "${match[1]}" == "ahead" ]]; then
#              s+="${ICON_FOR_UP}${match[2]} "
#            else
#              s+="${ICON_FOR_DOWN}${match[2]} "
#            fi
#          fi
#
#        fi
#
#        # Check for uncommitted changes in the index.
#        if ! $(git diff --quiet --no-ext-diff --ignore-submodules --cached); then
#          s+="+"
#        fi
#
#        # Check for unstaged changes.
#        if ! $(git diff-files --quiet --ignore-submodules -- 2>/dev/null); then
#          s+="!"
#        fi
#
#        # Check for untracked files.
#        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
#          s+="?"
#        fi
#
#        # Check for stashed files.
#        if $(git rev-parse --verify refs/stash &>/dev/null); then
#          s+="$"
#        fi
#
#        # The number of commits ahead/behind ends with a trailing space. If no other indicator was added, it will be lingering at the end of `s`.
#        s=$(echo "${s}" | sed 's/ *$//')
#
#        export GIT_INDEX_FILE="$__GIT_INDEX_FILE_ORIG"
#        # "rm" the temporary index.
#        rm "$__GIT_INDEX_PROMPT" 2>/dev/null
#      fi
#    else
#      s="-";
#      if [[ $(git config --get core.autocrlf) != "true" ]]; then
#        s+=" CRLF";
#      fi
#      if [[ $(git config --get core.filemode) != "false" ]]; then
#        s+=" FILEMODE";
#      fi
#    fi
#
#    # Get the short symbolic ref.
#    #
#    # If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
#    # Otherwise, just give up.
#    branchName="$({ LANG=C LANGUAGE=C git symbolic-ref --quiet HEAD 2>/dev/null || \
#      git rev-parse --short HEAD 2>/dev/null || \
#      echo '(unknown)'; } | sed 's/^refs\/heads\///')";
#
#    [[ -n "${s}" ]] && s=" [${s}]"
#
#    echo " (${branchName})${s}"
#  else
#    return
#  fi
#}
#
## -------------------------------------------------------------------
## svn_branch: helper for PS1
#__svn_branch()
#{
#  local svn_info=$(svn info 2>/dev/null)
#
#  echo $svn_info \
#    | sed -ne 's#^URL: ##p' \
#    | sed -e 's#^'"$(echo $svn_info | sed -ne 's#^Repository Root: ##p')"'##g' \
#    | awk '{print " ("$1")" }'
#}

## All the functions sit here tight

vix() {
  if [ -z "$1" ]; then
    echo "usage: $0 <newfilename>"
    return 1
  fi
  if [ ! -e "$1" ]; then
    echo -e "#!/usr/bin/env bash\n\nset -eo pipefail\n" > "$1"
  fi
  chmod -v 0755 "$1"
  vim -c 'normal Go' "$1"
}

# Make a new command in ~/bin
makecommand() {
  if [ -z "$1" ]; then
    echo "Command name required" >&2
    return 1
  fi

  mkdir -p ~/bin
  local cmd=~/bin/$1
  if [ -e $cmd ]; then
    echo "Command $1 already exists" >&2
  else
    if [ -z "$2" ]; then
      echo -e "#!/usr/bin/env bash\n\nset -eo pipefail\n" >$cmd
    else
      echo "#!/usr/bin/env $2" >$cmd
    fi
  fi

  vix $cmd
}

# View a Python module in Vim.
vipy() {
  p=`python -c "import $1; print $1.__file__.replace('.pyc','.py')"`
  if [ $? = 0 ]; then
    vi -R "$p"
  fi
  # errors will be printed by python
}

rxvt-title() {
  echo -n "]2;$*"
}

