# dotfiles
All my dotfiles at one place

```
      ██            ██     ████ ██  ██
     ░██           ░██    ░██░ ░░  ░██
     ░██  ██████  ██████ ██████ ██ ░██  █████   ██████
  ██████ ██░░░░██░░░██░ ░░░██░ ░██ ░██ ██░░░██ ██░░░░
 ██░░░██░██   ░██  ░██    ░██  ░██ ░██░███████░░█████
░██  ░██░██   ░██  ░██    ░██  ░██ ░██░██░░░░  ░░░░░██
░░██████░░██████   ░░██   ░██  ░██ ███░░██████ ██████
 ░░░░░░  ░░░░░░     ░░    ░░   ░░ ░░░  ░░░░░░ ░░░░░░

  ▓▓▓▓▓▓▓▓▓▓
 ░▓ about  ▓ custom linux config files
 ░▓ author ▓ Harsh Bhatt <root@thecloudmetro.com>
 ░▓        ▓ 
 ░▓        ▓ 
 ░▓▓▓▓▓▓▓▓▓▓
 ░░░░░░░░░░

```

### Using GNU stow to install dotfiles
I am using GNU stow to manage all my dotfiles. Make sure when executing any of
stow command go to the dir where your files that you want to install are located.

### xfiles
This contains all my x-files
- xinitrc
- Xmodmap
- xprofile
- Xresources
- Xresources-laptop

Installation `stow --dotfiles -v -R -t ~ apps`

### bash
I am not using bash much hence most of the config you will find in zsh section.
This contains following files
- bash_profile
- bashrc


### zsh
I am using oh-my-zsh and few plugins and fancy theme to make prompt more useful

Installation `stow --dotfiles -v -R -t ~ zsh`

### git
I have extensively customized my git configs also having a seperate config for work
and personal, which provides a great amount of flexibility in managing multiple
git accounts.

Installation `stow --dotfiles -v -R -t ~ git`

### i3wm
I have been using i3wm for over a decade now, this is my goto wm for all my linux
machines but i3wm works flawlessly on Arch, hence I prefer Arch over then any other
distro.

Installation `stow --dotfiles -v -R -t $HOME/.config/i3 i3`

### i3_blocks
Blocks are quite old, hence not using it anymore but if anyone is interested,
i3 blocks config are still alive.


### polybar

This is what I use for give bit of flavour to my i3wm. I am using it for triple
monitor setup but you can easily adapt it to any number of monitors.

Installation `stow --dotifles -v -R -t $HOME/.config/polybar polybar`


### tmux

This is my all time favourite application to make my life easier on terminals.
I am using a version of [gpakosz/.tmux](https://github.com/gpakosz/.tmux) with
few customization according to my tastes.

Install tmux from gpakosz repo and then install the custom local file which will
add all the goodies on top of it.

Installation 

`stow --dotfiles -v -R -t ~ dot-tmux.conf.local`

For tmux plugin manager and other tmux plugins that I use can be installed via

`stow --dotfiles -v -R -t $HOME/.tmux tmux`

### vim

Die-hard fan forever. Heavily using vim, I am using vim inspired keybindings everywhere,
even while using visual studio code.

Installation

### conf

System based conf file which I like to have a backup to speed up future provisionig
process.

### apps

Application config file for some applications that I care for

Installation `stow --dotfiles -v -R -t ~ apps`
