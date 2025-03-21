#!/bin/bash

# System Cleanup Script
echo "Cleaning up system..."
sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /tmp/*
sudo rm -rf ~/.cache/*
echo "System cleanup complete!"
