#!/bin/sh

echo "Updating package lists..."
sudo apt update

echo "Upgrading installed packages..."
sudo apt upgrade -y

echo "Cleaning up unnecessary packages..."
sudo apt autoremove -y

echo "System update completed!"
