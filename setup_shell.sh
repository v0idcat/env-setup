#!/bin/bash
# Custom shell setup script 1.3

if [ "$(id -u)" = "0" ]; then 
    echo "Please do NOT run as root!"
    exit
elif [ "$(command -v sudo)" = "" ]; then
    echo "Please install sudo first."
    exit
fi

error_log="./setup_error.log"

echo "[*] Updating & installing toolset ..."
sudo apt update -y 1>/dev/null 2>>"$error_log" && \
sudo apt install curl -y 1>/dev/null 2>>"$error_log" && \
sudo apt install git -y 1>/dev/null 2>>"$error_log" && \
sudo apt install tmux -y 1>/dev/null 2>>"$error_log" && \
sudo apt install vim -y 1>/dev/null 2>>"$error_log" && \
sudo apt install zsh -y 1>/dev/null 2>>"$error_log"

echo "[*] Setting up shell ..."
# If current user's shell isn't zsh, change default shell to zsh.
if [ $(echo $SHELL) != '/bin/zsh' ]; then
    chsh -s /bin/zsh $(logname)
    
fi

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "alias 'lsa=ls -lah --color=auto'" >> /home/"$(logname)"/.zshrc 2>>"$error_log"

# Set up tmux conf
echo "[*] Setting up tmux configs ..."
cat >> /home/"$(logname)"/.tmux.conf << EOF
# Send Prefix/Bind Key, replacing the default "Ctrl+b" of tmux,
# with "Alt+a" - Note that "Alt" is "Meta", specified as "M".

# OLD DATA
# set-option -g prefix M-a
# unbind-key M-a
# bind-key M-a send-prefix
# END OLD DATA

unbind C-b
set -g prefix C-a
bind C-a send-prefix


# Set scrollback buffer to 10k lines

set -g history-limit 10000


# Allows user to switch panes by using "Ctrl+Arrow Key",
# without the use of a prefix (in this case, "Alt+a").

# bind -n C-Left select-pane -L
# bind -n C-Right select-pane -R
# bind -n C-Up select-pane -U
# bind -n C-Down select-pane -D


# Shift+arrow to switch windows.

bind -n S-Left previous-window
bind -n S-Right next-window


# Split window by pressing "Ctrl+a" & "/" or "-".

bind-key - split-window -v
bind-key / split-window -h


# Reload config file while tmux is running.
# Meaning, you don't have to reset tmux everytime.
# Just type "Ctrl+a" and "R"

bind-key r source-file ~/.tmux.conf \; display-message "~/.tmux.conf reloaded."

# Load tmux theme automatically.
run-shell "tmux source-file /etc/tmux-themepack/blue.tmuxtheme"
EOF
sudo chown $(logname):$(logname) /home/"$(logname)"/.tmux.conf 

echo "[*] Setting up tmux theme ..."
sudo mkdir -p /etc/tmux-themepack/
wget https://raw.githubusercontent.com/jimeh/tmux-themepack/master/powerline/double/blue.tmuxtheme 1>/dev/null 2>>"$error_log"
sudo mv blue.tmuxtheme /etc/tmux-themepack/ 2>>"$error_log"

# Set up vim
echo "[*] Setting up vim ..."

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Setting up vimrc
cat >> /home/"$(logname)"/.vimrc << EOF
" vim-plug: https://github.com/junegunn/vim-plug 
vim9script
plug#begin()

Plug 'girishji/vimcomplete'

plug#end()

" CUSTOM SETTINGS BELOW
set number
set cursorline
"set cursorcolumn
set nowrap
set history=1000
" Enable autocompletion using tab
set wildmenu
EOF

echo -e "\n[+] Setup complete!\n"
echo -e "[*] To complete the zsh setup, run the following commands:\n"
echo "autoload -U zsh-newuser-install"
echo "zsh-newuser-install -f"
