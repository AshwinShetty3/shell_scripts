#!/bin/bash

# Docker installation script for Ubuntu
# Automates the process of installing Docker on Ubuntu-based systems

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Docker installation..."

# Update package index
echo "Updating package index..."
sudo apt update

# Install prerequisites
echo "Installing prerequisites..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
echo "Adding Docker repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
echo "Installing Docker..."
sudo apt update
sudo apt install -y docker-ce

# Add current user to the docker group to avoid using sudo with docker commands
echo "Adding current user to the docker group..."
sudo usermod -aG docker $USER

# Apply group changes
echo "Applying group changes..."
if [ -z "$SUDO_USER" ]; then
    # If not running with sudo, directly use newgrp
    newgrp docker
else
    # If running with sudo, inform the user to log out and log back in
    echo "Please log out and log back in for the group changes to take effect."
    echo "Alternatively, you can run 'newgrp docker' to apply changes for the current session."
fi

# Verify installation
echo "Docker installation complete! Verifying installation..."
docker --version

echo "Docker has been successfully installed!"
echo "You may need to log out and log back in for the docker group changes to take effect."