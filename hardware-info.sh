#!/usr/bin/env bash
# ------------------------------------------------------------------------ #
# Script Name:   hardware_machine.sh 
# Description:   Show information about machine hardware.
# Written by:    Amaury Souza
# Maintenance:   Amaury Souza
# ------------------------------------------------------------------------ #
# Usage:         
#       $ ./hardware_machine.sh
# ------------------------------------------------------------------------ #
# Bash Version:  
#              Bash 4.4.19
# ------------------------------------------------------------------------ #

# Function to display CPU model
function processador () {
    CPU_INFO=$(grep -m1 "^model name" /proc/cpuinfo | cut -d ":" -f2)
    echo "CPU model: $CPU_INFO"
}

# Function to display Kernel version
function kernel () {
    echo "Kernel version: $(uname -r)"
}

# Function to list installed software
function softwares () {
    echo "Choose an option below for the program list:
    
    1 - List Ubuntu programs
    2 - List Fedora programs
    3 - Install programs
    4 - Back to menu"
    echo " "
    read -rp "Chosen option: " alternative
    case $alternative in
        1)
            if command -v dpkg &> /dev/null; then
                echo "Listing all installed programs (Ubuntu)..."
                dpkg -l > /tmp/programs.txt
                echo "Programs listed and available at /tmp/programs.txt"
            else
                echo "dpkg not found. Are you running Ubuntu/Debian?"
            fi
            ;;
        2)
            if command -v yum &> /dev/null; then
                echo "Listing all installed programs (Fedora)..."
                yum list installed > /tmp/programs.txt
                echo "Programs listed and available at /tmp/programs.txt"
            else
                echo "yum not found. Are you running Fedora?"
            fi
            ;;
        3)
            echo "Installing common programs..."
            LIST_OF_APPS="pinta brasero gimp vlc inkscape blender filezilla"
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y $LIST_OF_APPS
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y $LIST_OF_APPS
            else
                echo "No supported package manager found."
            fi
            ;;
        4)
            echo "Returning to main menu..."
            return
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Function to display OS version
function sistema () {
    if [ -f /etc/os-release ]; then
        grep -i "^PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"'
    else
        echo "System not supported"
    fi
}

# Function to check available memory
function memory () {
    MEMORY_FREE=$(free -m | awk '/^Mem:/ {print $4}')
    echo "Memory free: ${MEMORY_FREE}MB"
}

# Function to get the system serial number
function serial () {
    if command -v dmidecode &> /dev/null; then
        sudo dmidecode -t 1 | grep -i "Serial Number"
    else
        echo "dmidecode not found. Run as root or install dmidecode."
    fi
}

# Function to get system IP address
function ip () {
    echo "System IP: $(hostname -I | awk '{print $1}')"
}

# Main Menu
function menuprincipal () {
    clear
    echo " "
    echo $0
    echo " "
    echo "Choose an option below!

    1 - Verify desktop processor
    2 - Verify system kernel
    3 - Verify installed software
    4 - Operating system version
    5 - Verify desktop memory
    6 - Verify serial number
    7 - Verify system IP
    0 - Exit"
    echo " "
    read -rp "Chosen option: " opcao

    case $opcao in
        1) processador ;;
        2) kernel ;;
        3) softwares ;;
        4) sistema ;;
        5) memory ;;
        6) serial ;;
        7) ip ;;
        0) echo "Exiting..." && exit 0 ;;
        *) echo "Invalid option, try again!" ;;
    esac
    read -n 1 -s -r -p "<Enter> to return to main menu"
    menuprincipal
}

menuprincipal

