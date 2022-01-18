# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

######################### Navigation ########################


alias .1='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias -- -='cd -'
alias cdd='cd -'  # back to last directory

if [[ "$SHELL" == "$(which zsh 2>/dev/null)" ]]; then
  alias 1='cd -'
  alias 2='cd -2'
  alias 3='cd -3'
  alias 4='cd -4'
  alias 5='cd -5'
  alias 6='cd -6'
  alias 7='cd -7'
  alias 8='cd -8'
  alias 9='cd -9'
fi

alias dots="cd ~/dotfiles;ls"
alias fa="cd ~/dotfiles/function_and_aliases;ls"
alias i3="cd ~/dotfiles/i3/i3/;ls"
alias poly="cd ~/dotfiles/polybar/;ls"
alias scripts="cd ~/scripts;ls"
alias dl='cd ~/Downloads;ls'
alias pydot='pycharm ~/dotfiles'
alias pyscript='pycharm ~/scirpts'
alias i3poly="vim ~/.config/polybar/config"
alias xinit="vim ~/.xinitrc"
alias xpro="vim ~/.xprofile"
alias brc="vim ~/.bashrc"
alias zrc="vim ~/.zshrc"
alias vrc="vim ~/.vimrc"
alias bpro="vim ~/.bash_profile"
alias xre="vim ~/.Xresource"
alias h="history"
alias jj="jobs"
alias clr="clear"
alias etc="cd /etc ; ls"
alias ex="exit"

## enable color support of ls and also add handy aliases
 if [ -x /usr/bin/dircolors  ]; then
         # shellcheck disable=SC2015
         test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
         alias dir='dir --color=auto'
         alias vdir='vdir --color=auto'
         alias grep='grep --color=auto'
         alias fgrep='fgrep --color=auto'
         alias egrep='egrep --color=auto'
 fi

##################### Useful Commands ####################

 # Portable ls with colors
#if ls --color -d . >/dev/null 2>&1; then
#  alias ls='ls --color=auto'  # Linux
#elif ls -G -d . >/dev/null 2>&1; then
#  alias ls='ls -G'  # BSD/OS X
#fi


# Detect which `ls` flavor is in use
#if ls --color > /dev/null 2>&1; then # GNU `ls`
#        colorflag="--color"
#else # OS X `ls`
#        colorflag="-G"
#fi

# List all files colorized in long format, including dot files
#alias la="ls -laFh ${colorflag}"

# List only directories
#alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

# Always use color output for `ls`
# shellcheck disable=SC2139
#alias ls="command ls ${colorflag}"
#export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'



# Laptop Backlight
alias low="xbacklight -set 10"
alias med="xbacklight -set 30"
alias high="xbacklight -set 50"

alias rm='trash' # Use `trash` program instead of built-in irrecoverable way to delete nodes.
#alias rm='rm -i'
#alias rmf='rm -rf'
for c in  chmod chown ; do
  alias $c="$c -v"
done
alias cp='cp --interactive --verbose' # Copy nodes with interactive mode and extra verbosity.
alias mv='mv --interactive --verbose' # Move nodes with interactive mode and extra verbosity.
alias ln='ln --interactive --verbose' # Link nodes with interactive mode and extra verbosity.
alias mkdir='mkdir --parents --verbose' # Make missing parent directories when creating folders.
alias grep='grep --color=auto --exclude-dir=".git" --exclude-dir="node_modules"' # Grep with colors and ignore common directories.
alias tmp='command mkdir --parents --verbose $TMPDIR/$(whoami) && cd $TMPDIR/$(whoami)' # Make temporary directory and cd into that.
alias du='du --max-depth=1 --si' # Display size of files and folders under current directory.
alias df='df --all --si --print-type' # Display all disk usage statistics with SI units and FS types.
alias ls='ls --almost-all --classify --color=always --group-directories-first --literal' # List name of nodes.
alias la='ls -l --almost-all --si' # List nodes with their details.
alias lf='ls -l | grep "^-"'
alias l.f='ls -ld .* | grep "^-"'
alias ld='ls -l | grep "^d"'
alias l.d='ls -ld .* | grep "^d"'
alias lsd="ls -lFh $COLORFLAG | grep --color=never '^d'"
alias lS="ls -1FSshr"
alias lr="ls -laFhtr"
alias lt="ls -altr | grep -v '^d' | tail -n 10" # last 10 recently changed files
alias llr="ls -lartFh --group-directories-first" # most recently modified files at bottom
alias lf="find ./* -ctime -1 | xargs ls -ltr" #files and dir that was touched in last hour
#alias preview='fzf --height=50% --layout=reverse --preview="bat --color=always {}"'
#alias cat='bat'
alias ch='echo > ~/.bash_history && echo > ~/.zsh_history'
alias cz='echo > ~/.z'
#alias open="xdg-open"
# Check for various OS openers. Quit as soon as we find one that works.
for opener in browser-exec xdg-open cmd.exe cygstart "start" open; do
        if command -v $opener >/dev/null 2>&1; then
                if [[ "$opener" == "cmd.exe"  ]]; then
                        # shellcheck disable=SC2139
                        alias open="$opener /c start";
                else
                        # shellcheck disable=SC2139
                        alias open="$opener";
                fi
                break;
          fi
done
alias tree="tree -Chsu"
alias ltree="tree -Chsu | less -R"



###################### Search ###########################

alias fdir='find . -type d -name'
alias ff='find . -type f -name'
alias lgrep='ls -l | grep'
alias lagrep='ls -lA | grep'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,.tldr,node_modules,Trash,vendor}'
alias sgrep2='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '
alias hgrep='history | grep'
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
#alias map="xargs -n1"


##################### disk utilities ############################

alias free='free -h'
alias disk='df -h | grep sd \
    | sed -e "s_/dev/sda[1-9]_\x1b[34m&\x1b[0m_" \
    | sed -e "s_/dev/sd[b-z][1-9]_\x1b[33m&\x1b[0m_" \
    | sed -e "s_[,0-9]*[MG]_\x1b[36m&\x1b[0m_" \
    | sed -e "s_[0-9]*%_\x1b[32m&\x1b[0m_" \
    | sed -e "s_9[0-9]%_\x1b[31m&\x1b[0m_" \
    | sed -e "s_/mnt/[-_A-Za-z0-9]*_\x1b[34;1m&\x1b[0m_"'
alias diskspace_report="df -P -kHl"
alias free_diskspace_report="diskspace_report"
alias udisk='udisksctl unmount -b /dev/sdb1;udisksctl unmount -b /dev/dm-0;udisksctl lock -b /dev/sdb2;udisksctl power-off -b /dev/sdb;'
alias mdisk='udisksctl unlock -b /dev/sdb2;udisksctl mount -b /dev/dm-0;'
#alias pc2toshibaDocuments='sudo rsync -e "sudo -u cris" -avzh --progress /home/arch/Documents/ /run/media/arch/Toshiba2/Documents'
#alias pc2toshibaMusic='sudo rsync -e "sudo -u arch" -avzh --delete --progress /home/arch/Music_clean/ /run/media/arch/Toshiba/Music_clean/'
#alias pc2toshibaPictures='sudo rsync -e "sudo -u arch" -avzh --progress /home/arch/Images/ /run/media/arch/Toshiba2/Pictures/'
#alias pc2toshibaMail='sudo rsync -e "sudo -u arch" -avzh --progress /home/arch/.mail/ /run/media/arch/Toshiba2/Mail/'
#alias pc2toshibaVideos='sudo rsync -e "sudo -u cris" -avzh --progress /home/cris/Videos/ /run/media/cris/Toshiba2/Videos/'
#alias toshiba2pcDocuments='rsync -avzh --delete --progress /run/media/cris/Toshiba2/Clases/ /home/cris/Documents/'
#alias toshiba2pcMusic='sudo rsync -e "sudo -u arch" -avzh --progress /run/media/arch/Toshiba/Music/ /home/arch/Music/'
#alias toshiba2pcPictures='rsync -avzh --delete --progress /run/media/cris/Toshiba2/Pictures/ /home/cris/Images/'
# sudo rsync -e "sudo -u arch" -avzh --progress /run/media/arch/Toshiba2/Clases/Papeles /home/arch/Documents/
alias rsync_cmd="echo 'rsync -az --progress server:/path/ path (Slashes are significant.)'"
alias rsync='rsync --protect-args --compress --verbose --progress --human-readable'







####################### system ##########################

alias pg='ps aux | head -n1; ps aux | grep -i'
alias htop-user='htop -u "$USER"'
alias incognito='unset HISTFILE'
alias p='ps axo pid,user,pcpu,comm'
alias uptime='uptime -p'
alias cleands="find . -type f -name '*.DS_Store' -ls -delete"
alias afk="i3lock 30 -e -f -n -i ~/Pictures/lock.png"
alias alert='notify-send --urgency=low -i "$([ $? = 0  ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"
alias pbcopy='xclip -selection clipboard -i'
alias pbpaste='xclip -selection clipboard -o'
# Clipboard access. I created these aliases to have the same command on
# Cygwin, Linux and OS X.
if command -v pbpaste >/dev/null; then
  alias getclip="pbpaste"
  alias putclip="pbcopy"
elif command -v xclip >/dev/null; then
  alias getclip="xclip -selection clipboard -o"
  alias putclip="xclip -selection clipboard -i"
elif [[ "$SYSTEM_TYPE" == "MINGW" || "$SYSTEM_TYPE" == "CYGWIN" ]]; then
  alias getclip="cat /dev/clipboard"
  alias putclip="cat > /dev/clipboard"
fi

# Trim new lines and copy to clipboard
alias pc="putclip"
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias dmesg='dmesg -T'
alias reload='source ~/.zshrc && echo "sourced ~/.zshrc"'
alias reload_bash='source ~/.basrc && echo "source ~/.bashrc"'
alias path="echo -e ${PATH//:/\\n}"
if command -v htop >/dev/null; then
    alias top_orig="/usr/bin/top"
    alias top="htop"
fi
# pass options to free
alias meminfo="free -m -l -t"
# get top process eating memory
alias psmem="ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 6"
alias psmem5="psmem | tail -5"
alias psmem10="psmem | tail -10"
# get top process eating cpu
alias pscpu="ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 5"
alias pscpu5="pscpu5 | tail -5"
alias pscpu10="pscpu | tail -10"
# shows the corresponding process to ...
alias psx="ps auxwf | grep "
# shows the process structure to clearly
alias pst="pstree -Alpha"
# shows all your processes
alias psmy="ps -ef | grep $USER"
# the load-avg
alias loadavg="cat /proc/loadavg"
# show all partitions
alias partitions="cat /proc/partitions"
# becoming root + executing last command
alias sulast='su -c !-1 root'
alias emptytrash="rm -rfv ~/.local/share/Trash/*"


#################### Utilties #################

alias mp3-dl='youtube-dl --ignore-config --extract-audio \
    --audio-format "mp3" --audio-quality 0 --embed-thumbnail \
    --add-metadata --metadata-from-title "%(artist)s - %(title)s" \
    --output "$HOME/Downloads/%(title)s.%(ext)s"'
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'
alias timer2='echo "Timer started. Stop with Ctrl-D." && date "+%a, %d %b %H:%M:%S" && time cat && date "+%a, %d %b %H:%M:%S"'
alias date_iso_8601='date "+%Y%m%dT%H%M%S"'
alias date_clean='date "+%Y-%m-%d"'
alias date_year='date "+%Y"'
alias date_month='date "+%m"'
alias date_week='date "+%V"'
alias date_day='date "+%d"'
alias date_hour='date "+%H"'
alias date_minute='date "+%M"'
alias date_second='date "+%S"'
alias date_time='date "+%H:%M:%S"'

# Enabled aliases to be sudo'ed
alias sudo='sudo'
alias _='sudo'
alias please='sudo'

# Use GRC for additionnal colorization
  if which grc >/dev/null 2>&1; then
    alias colour="grc -es --colour=auto"
    alias as="colour as"
    alias configure="colour ./configure"
    alias diff="colour diff"
    alias dig="colour dig"
    alias g++="colour g++"
    alias gas="colour gas"
    alias gcc="colour gcc"
    alias head="colour head"
    alias ifconfig="colour ifconfig"
    alias make="colour make"
    alias mount="colour mount"
    alias netstat="colour netstat"
    alias ping="colour ping"
    alias ps="colour ps"
    alias tail="colour tail"
    alias traceroute="colour traceroute"
    alias syslog="sudo colour tail -f -n 100 /var/log/syslog"
  fi

# ring the terminal bell, and put a badge on Terminal.app’s Dock icon
# (useful when executing time-consuming commands)
alias badge="tput bel"

# decimal to hexadecimal value
alias dec2hex='printf "%x\n" $1'

# urldecode - url http network decode
alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])"'

# urlencode - url encode network http
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'

# ROT13-encode text. Works for decoding, too! ;)
alias rot13='tr a-zA-Z n-za-mN-ZA-M'


################################ tmux ################
alias ta="tmux attach -t host"


##### files to be copied to start laptop in edp1 or hdmi1 mode #####
#alias tdark='cp ~/.config/termite/configSolarizedDark ~/.config/termite/config'
#alias tlight='cp ~/.config/termite/configSolarizedLight ~/.config/termite/config'
#alias tgruv='cp ~/.config/termite/configGruv ~/.config/termite/config'

#alias graf='grafana-server --config=/home/arch/.config/grafana/grafana.ini --homepath=/usr/share/grafana'


####################### yet to finalize ################3
#
## IP addresses
#
##alias ips="sudo ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print  }'"
#
#
#
#
#
#
#
## Custom Shortcuts
#
# #alias bwlogin='bw login --code "$(auth bitwarden)" "$(< .mutt/accounts/com.gmail/email.txt)" "$(gpg --no-tty --quiet --decrypt ~/.bitwarden/secret.gpg)"'
# #alias bwunlock='export BW_SESSION="$(bw unlock --raw $(gpg --no-tty --quiet --decrypt ~/.bitwarden/secret.gpg))"'
#
#
##alias l='ls -l'
##alias la='ls -lA'
##alias lr='ls -R'
#
#alias dud='du -d 1 -h'
#alias duf='du -sh *'
#
#
#export EDITOR=vim
#
################
##  gpg-agent  #
################
## GPG variables
#GPG_TTY=$(tty)
#export GPG_TTY
#
#
## Compatibility for ssh connection
#export TERM=xterm-256color
#
#
#
#
#############
##  Others  #
#############
#
#export PATH=/home/arch/.local/bin:$PATH
#
#
#
#alias co='git checkout'
#alias cr2lf="perl -pi -e 's/\x0d/\x0a/gs'"
#alias curltime='curl -w "@$HOME/.curl-format" -o /dev/null -s'
#alias d='docker'
#alias dc='docker-compose'
#alias dls='dpkg -L'
#alias dotenv="eval \$(egrep -v '^#' .env | xargs)"
#alias dsl='dpkg -l | grep -i'
#alias dud='du -sh -- * | sort -h'
#alias e='emacs'
#alias ec='emacsclient --no-wait'
#alias f1="awk '{print \$1}'"
#alias f2="awk '{print \$2}'"
#alias f2k9='f2k -9'
#alias f2k='f2 | xargs -t kill'
#alias f='fg'
#alias fixssh='eval $(tmux showenv -s SSH_AUTH_SOCK)'
#
#alias i4='sed "s/^/    /"'
#alias icat='lsbom -f -l -s -pf'
#alias iinstall='sudo installer -target / -pkg'
#alias ils='ls /var/db/receipts/'
#alias ishow='pkgutil --files'
#alias k='tree -h'
#alias l="ls -lh"
#alias ll="l -a"
#alias lt='ls -lt'
#alias ltr='ls -ltr'
#alias ndu='node --debug-brk =nodeunit'
#alias nerdcrap='cat /dev/urandom | xxd | grep --color=never --line-buffered "be ef"'
#alias netwhat='lsof -i +c 40'
#alias nmu='nodemon =nodeunit'
#alias notifydone='terminal-notifier -message Done.'
#alias pt='pstree -pul'
#alias px='pilot-xfer -i'
#alias rake='noglob rake'
#alias randpass="LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24 ; echo"
#alias rgg='_rgg () { rg --color always --heading $@ | less }; _rgg'
#alias ri='ri -f ansi'
#alias rls='screen -ls'
#alias rrg='rgg'
#alias rsync-usual='rsync -azv -e ssh --delete --progress'
#alias rxvt-invert="echo -n '[?5t'"
#alias rxvt-scrollbar="echo -n '[?30t'"
#alias scp='scp -C -p'
#alias screen='screen -U'
#alias slurp='wget -t 5 -c -nH -r -k -p -N --no-parent'
#alias sshx='ssh -C -c blowfish -X'
#alias st='git status'
#alias stt='git status -uall'
#alias t='tmux attach'
#alias tree="tree -F -A -I CVS"
#alias tt='tail -n 9999'
#alias wgetdir='wget -r -l1 -P035 -nd --no-parent'
#alias whois='whois -h geektools.com'
#
#
#
## add ssh-key to ssh-agent when key exist
#if [ "$SSH_AUTH_SOCK" != "" ] && [ -f ~/.ssh/id_rsa ] && [ -x /usr/bin/ssh-add  ]; then
#  ssh-add -l >/dev/null || alias ssh='(ssh-add -l >/dev/null || ssh-add) && unalias ssh; ssh'
#fi
#
#
## add ssh-key to ssh-agent when key exist
#if [ "$SSH_AUTH_SOCK" != "" ] && [ -f "~/.ssh/id_rsa" ] && [ -x "/usr/bin/ssh-add"  ]; then
#  ssh-add -l >/dev/null || alias ssh='(ssh-add -l >/dev/null || ssh-add) && unalias ssh; ssh'
#fi
#
#
#
#
#
## ------------------------------------------------------------------------------
## | auto-completion (for bash)                                                 |
## ------------------------------------------------------------------------------
#
## Automatically add completion for all aliases to commands having completion functions
## source: http://superuser.com/questions/436314/how-can-i-get-bash-to-perform-tab-completion-for-my-aliases
#alias_completion()
#{
#  local namespace="alias_completion"
#
#  # parse function based completion definitions, where capture group 2 => function and 3 => trigger
#  local compl_regex='complete( +[^ ]+)* -F ([^ ]+) ("[^"]+"|[^ ]+)'
#  # parse alias definitions, where capture group 1 => trigger, 2 => command, 3 => command arguments
#  local alias_regex="alias ([^=]+)='(\"[^\"]+\"|[^ ]+)(( +[^ ]+)*)'"
#
#  # create array of function completion triggers, keeping multi-word triggers together
#  eval "local completions=($(complete -p | sed -rne "/$compl_regex/s//'\3'/p"))"
#  (( ${#completions[@]} == 0 )) && return 0
#
#  # create temporary file for wrapper functions and completions
#  rm -f "/tmp/${namespace}-*.XXXXXXXXXX" # preliminary cleanup
#  local tmp_file="$(mktemp "/tmp/${namespace}-${RANDOM}.XXXXXXXXXX")" || return 1
#
#  # read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
#  local line; while read line; do
#    eval "local alias_tokens=($line)" 2>/dev/null || continue # some alias arg patterns cause an eval parse error
#    local alias_name="${alias_tokens[0]}" alias_cmd="${alias_tokens[1]}" alias_args="${alias_tokens[2]# }"
#
#    # skip aliases to pipes, boolan control structures and other command lists
#    # (leveraging that eval errs out if $alias_args contains unquoted shell metacharacters)
#    eval "local alias_arg_words=($alias_args)" 2>/dev/null || continue
#
#    # skip alias if there is no completion function triggered by the aliased command
#    [[ " ${completions[*]} " =~ " $alias_cmd " ]] || continue
#    local new_completion="$(complete -p "$alias_cmd")"
#
#    # create a wrapper inserting the alias arguments if any
#    if [[ -n $alias_args ]]; then
#     local compl_func="${new_completion/#* -F /}"; compl_func="${compl_func%% *}"
#     # avoid recursive call loops by ignoring our own functions
#     if [[ "${compl_func#_$namespace::}" == $compl_func ]]; then
#       local compl_wrapper="_${namespace}::${alias_name}"
#         echo "function $compl_wrapper {
#           (( COMP_CWORD += ${#alias_arg_words[@]} ))
#           COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
#           $compl_func
#         }" >> "$tmp_file"
#         new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
#     fi
#    fi
#
#    # replace completion trigger by alias
#    new_completion="${new_completion% *} $alias_name"
#    echo "$new_completion" >> "$tmp_file"
#  done < <(alias -p | sed -rne "s/$alias_regex/\1 '\2' '\3'/p")
#  source "$tmp_file" && rm -f "$tmp_file"
#}
#if [ -n "$BASH_VERSION" ]; then
#  alias_completion
#fi
#unset -f alias_completion