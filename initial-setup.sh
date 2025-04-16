#!/bin/bash

# EC2 Instance Setup Script
# This script installs essential tools and packages on a new EC2 instance

# Exit on any error
set -e

# Print commands before execution
set -x

# Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# Upgrade installed packages
echo "Upgrading installed packages..."
sudo apt-get upgrade -y

# Install basic utilities
echo "Installing basic utilities..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    vim \
    unzip \
    zip \
    tar \
    htop \
    screen \
    tmux \
    build-essential \
    lsof \
    iotop \
    sysstat \
    ncdu \
    tree \
    rsync \
    jq \
    silversearcher-ag \
    ripgrep \
    fzf \
    lynx \
    ca-certificates

# Install Python and pip
echo "Installing Python and pip..."
sudo apt-get install -y \
    python2.7 \
    python3 \
    python-pip \
    python3-pip \
    python3-dev \
    python3-venv

# Upgrade pip
echo "Upgrading pip..."
sudo pip install --upgrade pip
sudo pip3 install --upgrade pip

# Install networking tools
echo "Installing networking tools..."
sudo apt-get install -y \
    net-tools \
    iputils-ping \
    traceroute \
    mtr \
    nmap \
    tcpdump \
    netcat \
    iftop \
    iptraf \
    whois \
    dnsutils \
    telnet \
    iproute2 \
    iperf3 \
    speedtest-cli \
    bind9-dnsutils

# Install AWS CLI
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Install Neovim
echo "Installing Neovim..."
sudo apt-get install -y neovim

# Create Neovim config directory
mkdir -p ~/.config/nvim

# Configure Neovim to use the same settings as Vim
echo "Configuring Neovim to use Vim settings..."
echo 'set runtimepath^=~/.vim runtimepath+=~/.vim/after' > ~/.config/nvim/init.vim
echo 'let &packpath = &runtimepath' >> ~/.config/nvim/init.vim
echo 'source ~/.vimrc' >> ~/.config/nvim/init.vim

# Set up Vim configuration
echo "Configuring Vim..."
cat > ~/.vimrc << 'EOL'
syntax on
set number
set shiftwidth=4
set cursorline
set mouse=a       " Enable mouse support
set incsearch     " Enable incremental search /name_to_find
filetype plugin indent on
" YAML indentation and whitespace highlighting
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml highlight BadWhitespace ctermbg=red guibg=red
autocmd FileType yaml match BadWhitespace /\s\+$/
" Dockerfile indentation
autocmd FileType dockerfile setlocal ts=4 sts=4 sw=4 expandtab
" Tokyo Night-inspired colors for Vim (without plugins)
set termguicolors
set background=dark
" Basic colors
highlight Normal ctermbg=NONE ctermfg=252 guibg=#1a1b26 guifg=#a9b1d6
highlight Comment ctermfg=244 guifg=#565f89
highlight Constant ctermfg=141 guifg=#bb9af7
highlight String ctermfg=114 guifg=#9ece6a
highlight Function ctermfg=75 guifg=#7aa2f7
highlight Identifier ctermfg=189 guifg=#c0caf5
highlight Statement ctermfg=204 guifg=#f7768e
highlight PreProc ctermfg=208 guifg=#ff9e64
highlight Type ctermfg=38 guifg=#2ac3de
highlight Special ctermfg=178 guifg=#e0af68
highlight Underlined ctermfg=81 guifg=#7dcfff
highlight Todo ctermfg=178 ctermbg=237 guifg=#e0af68 guibg=#3b4261
" CursorLine and Visual selection
highlight CursorLine ctermbg=236 guibg=#292e42
highlight Visual ctermbg=237 guibg=#28304a
" Tabline and Statusline
highlight TabLine ctermbg=NONE ctermfg=244 guibg=#1a1b26 guifg=#565f89
highlight StatusLine ctermbg=237 ctermfg=252 guibg=#3b4261 guifg=#a9b1d6
highlight StatusLineNC ctermbg=NONE ctermfg=244 guibg=#1a1b26 guifg=#565f89
EOL

# Set up system tweaks
echo "Setting up system tweaks..."

# Increase history size
echo 'export HISTSIZE=10000' >> ~/.bashrc
echo 'export HISTFILESIZE=10000' >> ~/.bashrc
echo 'export HISTCONTROL=ignoreboth:erasedups' >> ~/.bashrc
echo 'shopt -s histappend' >> ~/.bashrc

# Configure Bash to save each command to the history file immediately
echo 'PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"' >> ~/.bashrc

# Reduce swappiness for better performance (needs sudo)
if [ $(id -u) -eq 0 ]; then
    echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
    sysctl -p /etc/sysctl.d/99-swappiness.conf
else
    echo "To reduce swappiness (improves performance), run as root:"
    echo "echo \"vm.swappiness=10\" > /etc/sysctl.d/99-swappiness.conf"
    echo "sysctl -p /etc/sysctl.d/99-swappiness.conf"
fi

# Display system info at login
cat > ~/.motd << 'EOL'
#!/bin/bash
echo "$(tput setaf 2)
   ______ ____ ___    ____           __                     
  / ____// __ \__ \  /  _/____  ___ / /__ ____ ____  _____ 
 / __/  / / / /_/ /  / / / __ \/ __  // __// __// __ \/ ___/
/ /___ / /_/ / __/ _/ / / / / / /_/ // /_ / /__ / /_/ / /    
\____/ \____/____//___//_/ /_/\__,_/ \__/ \___/ \____//_/     
                                                          
$(tput sgr0)"
echo "$(tput bold)SYSTEM INFORMATION:$(tput sgr0)"
echo "$(tput setaf 3)Hostname:$(tput sgr0) $(hostname)"
echo "$(tput setaf 3)IP Address:$(tput sgr0) $(hostname -I | awk '{print $1}')"
echo "$(tput setaf 3)Kernel:$(tput sgr0) $(uname -r)"
echo "$(tput setaf 3)CPU:$(tput sgr0) $(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')"
echo "$(tput setaf 3)Memory:$(tput sgr0) $(free -h | grep Mem | awk '{print $2}')"
echo "$(tput setaf 3)Disk Space:$(tput sgr0) $(df -h / | awk 'NR==2 {print $2}')"
echo "$(tput setaf 3)Disk Used:$(tput sgr0) $(df -h / | awk 'NR==2 {print $5}')"
echo "$(tput setaf 3)Python Version:$(tput sgr0) $(python3 --version 2>&1)"
echo
echo "$(tput bold)SYSTEM LOAD:$(tput sgr0)"
echo "$(tput setaf 3)CPU Load:$(tput sgr0) $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
echo "$(tput setaf 3)Memory Usage:$(tput sgr0) $(free | grep Mem | awk '{print int($3/$2 * 100)}')%"
echo "$(tput setaf 3)Processes:$(tput sgr0) $(ps aux | wc -l)"
echo "$(tput setaf 3)Users Logged In:$(tput sgr0) $(who | wc -l)"
echo
echo "$(tput bold)NETWORK:$(tput sgr0)"
echo "$(tput setaf 3)Active Connections:$(tput sgr0) $(netstat -tn | grep ESTABLISHED | wc -l)"
EOL
chmod +x ~/.motd

# Add motd to bashrc
echo "# Display custom motd at login" >> ~/.bashrc
echo "if [ -f ~/.motd ]; then" >> ~/.bashrc
echo "    ~/.motd" >> ~/.bashrc
echo "fi" >> ~/.bashrc

# Set up environment variables
echo 'export PATH=$PATH:$HOME/bin:$HOME/.local/bin' >> ~/.bashrc
echo 'export EDITOR=vim' >> ~/.bashrc

# Clean up
echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

# Setup terminal colors
echo "Setting up terminal colors..."
# Set terminal to 256 colors
echo 'export TERM=xterm-256color' >> ~/.bashrc

# Setup a better bash prompt
echo 'PS1="\[\033[38;5;40m\]\u@\h\[$(tput sgr0)\]:\[\033[38;5;33m\]\w\[$(tput sgr0)\]\\$ "' >> ~/.bashrc

# Enable color support for ls
echo 'if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then' >> ~/.bashrc
echo '    alias ls="ls --color=auto"' >> ~/.bashrc
echo 'fi' >> ~/.bashrc

# Add more color aliases
echo 'alias grep="grep --color=auto"' >> ~/.bashrc
echo 'alias fgrep="fgrep --color=auto"' >> ~/.bashrc
echo 'alias egrep="egrep --color=auto"' >> ~/.bashrc
echo 'alias diff="diff --color=auto"' >> ~/.bashrc
echo 'alias ip="ip -color=auto"' >> ~/.bashrc

# Ensure .bashrc loads on SSH
echo 'if [ -f ~/.bashrc ]; then' >> ~/.profile
echo '    . ~/.bashrc' >> ~/.profile
echo 'fi' >> ~/.profile
# Apply changes
source ~/.bashrc
source ~/.profile

# Set up some useful Linux aliases
echo "Setting up useful Linux aliases..."
cat >> ~/.bashrc << 'EOL'

# Improved directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Enhanced listing commands
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lh'
alias lt='ls -ltr'

# Quick system info and monitoring
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias cpuinfo='lscpu'
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'

# Network shortcuts
alias ports='netstat -tulanp'
alias ping='ping -c 5'

# Command shortcuts
alias h='history'
alias j='jobs -l'
alias update='sudo apt-get update && sudo apt-get upgrade'
alias clean='sudo apt-get autoremove && sudo apt-get autoclean'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
EOL

echo "Setup complete! Your EC2 instance has been configured with the requested tools."
echo "System information:"
uname -a
python3 --version
pip3 --version
aws --version
