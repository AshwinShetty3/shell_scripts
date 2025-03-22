#!/bin/bash
#chmod +x setup-ec2-color.sh
#Run the script: ./setup_colors.sh
# Set terminal to 256 colors
#Verify settings: echo $TERM   # should return 'xterm-256color'
#ls --color=auto  # should show colored output

echo 'export TERM=xterm-256color' >> ~/.bashrc

# Enable color support for ls
echo 'if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then' >> ~/.bashrc
echo '    alias ls="ls --color=auto"' >> ~/.bashrc
echo 'fi' >> ~/.bashrc

# Ensure .bashrc loads on SSH
echo 'if [ -f ~/.bashrc ]; then' >> ~/.profile
echo '    . ~/.bashrc' >> ~/.profile
echo 'fi' >> ~/.profile

# Apply changes
source ~/.bashrc
source ~/.profile
