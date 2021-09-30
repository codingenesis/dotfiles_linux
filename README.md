
- [dotfiles](#dotfiles)
    - [Using GNU stow to install dotfiles](#using-gnu-stow-to-install-dotfiles)
    - [xfiles](#xfiles)
    - [bash](#bash)
    - [zsh](#zsh)
    - [git](#git)
    - [i3wm](#i3wm)
    - [i3_blocks](#i3_blocks)
    - [polybar](#polybar)
    - [tmux](#tmux)
    - [vim](#vim)
    - [conf](#conf)
    - [apps](#apps)
    - [Terminal theme color](#terminal-theme-color)

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
To install a specific file install the group instead of a specfic file.

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
I am using oh-my-zsh and few plugins and fancy theme to make prompt more useful.
I have created / copied useful funcitons and aliases over the period of time to
make my life easier on terminal.

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

Die-hard fan but to be frank using Visual Studio Code more heavily then vim, I am using vim inspired keybindings everywhere though.

I am using following vim plugins

- auto-pairs
- ctrlp.vim
- emmet-vim
- indentline
- molokai
- nerdcommenter
- nerdtree
- nerdtree-git-plugin
- python-mode
- supertab
- syntastic
- tagbar
- ultisnips
- undotree
- vim-airline
- vim-airline-themes
- vim-colorschemes
- vim-colors-solarized
- vim-devicons
- vim-easymotion
- vim-json
- vim-nerdtree-syntax-highlight
- vim-sensible
- vim-signify
- vim-snippets
- vim-surround

Installation ` stow --dotfiles -v -R -t ~ vim`

### conf

System based conf file which I like to have a backup to speed up future provisionig
process.

### apps

Application config file for some applications that I care for

- redshift
- tmux.conf.local
- wgetrc
- p10.zsh

Installation `stow --dotfiles -v -R -t ~ apps`

### Terminal theme color

|-----------------------|:------------------------|
|Color1 #172F4D  | Color9  #4A5B62  | 
|Color2 #C05351  | Color10 #C05351  |
|Color3 #509B22  | Color11 #D69215  |
|Color4 #A27B01  | color12 #CAB035  |
|Color5 #679BFF  | color13 #5AA2FF  |
|Color6 #6C71C4  | color14 #37AFF9  |
|Color7 #5D82EE  | color15 #568362  |
|Color8 #5D5D5D  | color16 #252525  |

Text Color #97ACB4
Background color dark bluish
