#!/bin/bash

# Fully automated load monitoring script with service setup
# One-time setup that creates a service and starts monitoring

# Formspree configuration
FORMSPREE_ENDPOINT="https://formspree.io/f/mpwzekgg"
EMAIL_TO="ashwinbshetty373@gmail.com"
THRESHOLD=80
COOLDOWN=600  # Changed from 600(10min) to 60 seconds for testing

# Function to perform the actual monitoring (will be run by the service)
start_monitoring() {
    echo "Starting continuous system monitoring..."
    echo "Monitoring CPU and memory for usage above ${THRESHOLD}%"
    echo "Alerts will be sent to Formspree endpoint"
    
    LAST_ALERT_TIME=0
    
    # Continuous monitoring loop
    while true; do
        # Get current date and time
        DATE=$(date "+%Y-%m-%d %H:%M:%S")
        CURRENT_TIME=$(date +%s)
        
        # Get hostname
        HOSTNAME=$(hostname)
        
        # Get CPU usage (using top command in batch mode)
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | awk '{printf "%.1f", $1}')
        CPU_USAGE_INT=${CPU_USAGE%.*}
        
        # Get memory usage
        MEMORY_TOTAL=$(free -m | grep Mem | awk '{print $2}')
        MEMORY_USED=$(free -m | grep Mem | awk '{print $3}')
        MEMORY_USAGE=$(awk "BEGIN {printf \"%.1f\", ($MEMORY_USED/$MEMORY_TOTAL)*100}")
        MEMORY_USAGE_INT=${MEMORY_USAGE%.*}
        
        # Create alert message
        ALERT_SUBJECT="HIGH RESOURCE USAGE ALERT"
        ALERT_MESSAGE="
Date: $DATE
Hostname: $HOSTNAME

"
        
        # Flag to track if we need to send an alert
        SEND_ALERT=0
        
        # Check CPU usage
        if [ "$CPU_USAGE_INT" -ge "$THRESHOLD" ]; then
            ALERT_MESSAGE+="CPU Usage: ${CPU_USAGE}% (Exceeds ${THRESHOLD}% threshold)
"
            SEND_ALERT=1
        else
            echo "$(date "+%Y-%m-%d %H:%M:%S") - CPU Usage: ${CPU_USAGE}% (Normal)"
        fi
        
        # Check memory usage
        if [ "$MEMORY_USAGE_INT" -ge "$THRESHOLD" ]; then
            ALERT_MESSAGE+="Memory Usage: ${MEMORY_USAGE}% (Exceeds ${THRESHOLD}% threshold)
"
            SEND_ALERT=1
        else
            echo "$(date "+%Y-%m-%d %H:%M:%S") - Memory Usage: ${MEMORY_USAGE}% (Normal)"
        fi
        
        # Calculate time since last alert
        TIME_SINCE_LAST=$((CURRENT_TIME - LAST_ALERT_TIME))
        
        # Send alert if either CPU or memory usage exceeds the threshold AND cooldown period has passed
        if [ "$SEND_ALERT" -eq 1 ] && [ "$TIME_SINCE_LAST" -ge "$COOLDOWN" ]; then
            # Add system information to the message
            ALERT_MESSAGE+="
System Information:
$(uptime)

Top 5 CPU-consuming processes:
$(ps aux --sort=-%cpu | head -6)

Top 5 Memory-consuming processes:
$(ps aux --sort=-%mem | head -6)
"
            
            # Use curl to send data to Formspree with full error output
            FORMSPREE_RESPONSE=$(curl -X POST "$FORMSPREE_ENDPOINT" \
              --form-string "email=$EMAIL_TO" \
              --form-string "subject=$ALERT_SUBJECT" \
              --form-string "message=$ALERT_MESSAGE" \
              -v 2>&1)
            
            # Log the complete response
            echo "$(date "+%Y-%m-%d %H:%M:%S") - DEBUG: Complete Formspree Response:"
            echo "$FORMSPREE_RESPONSE"
            
            # Check if response contains success indicator
            if echo "$FORMSPREE_RESPONSE" | grep -q '"ok":true'; then
                echo "$(date "+%Y-%m-%d %H:%M:%S") - ALERT SENT SUCCESSFULLY: CPU: ${CPU_USAGE}%, Memory: ${MEMORY_USAGE}%"
            else
                echo "$(date "+%Y-%m-%d %H:%M:%S") - ERROR: Failed to send alert"
            fi
            echo "$(date "+%Y-%m-%d %H:%M:%S") - ALERT SENT: CPU: ${CPU_USAGE}%, Memory: ${MEMORY_USAGE}%"
            LAST_ALERT_TIME=$CURRENT_TIME
        elif [ "$SEND_ALERT" -eq 1 ]; then
            echo "$(date "+%Y-%m-%d %H:%M:%S") - HIGH USAGE DETECTED but in cooldown period. Next alert available in $((COOLDOWN - TIME_SINCE_LAST)) seconds."
        fi
        
        # Sleep for 30 seconds before checking again
        sleep 30
    done
}

# Function to setup the service
setup_service() {
    # Check if running as root for service setup
    if [ "$EUID" -ne 0 ]; then
        echo "Root privileges needed for service setup. Running with sudo..."
        # Re-run the script with sudo and pass the current path
        sudo "$0" "--internal-setup" "$SCRIPT_PATH"
        exit $?
    fi
    
    echo "Setting up system service for automatic startup..."
    
    # Create the systemd service file
    cat > /etc/systemd/system/load-notifier.service << EOF
[Unit]
Description=System Load Notifier Service
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH
Restart=always
RestartSec=10
StandardOutput=append:/var/log/load-notifier.log
StandardError=append:/var/log/load-notifier.log

[Install]
WantedBy=multi-user.target
EOF
    
    # Create log file with proper permissions
    touch /var/log/load-notifier.log
    chmod 644 /var/log/load-notifier.log
    
    # Enable and start the service
    systemctl daemon-reload
    systemctl enable load-notifier.service
    systemctl start load-notifier.service
    
    echo "Service has been created and started!"
    echo "The monitoring is now running in the background"
    echo "Check status with: systemctl status load-notifier.service"
    echo "View logs with: tail -f /var/log/load-notifier.log"
}

# Main script logic
SCRIPT_PATH=$(realpath "$0")

# Check for special internal setup flag (used when script re-invokes itself with sudo)
if [ "$1" == "--internal-setup" ] && [ -n "$2" ]; then
    SCRIPT_PATH="$2"
    setup_service
    exit 0
fi

# Check if this script is being run by systemd
if [ "${INVOCATION_ID:-}" != "" ] || [ "${USER:-}" = "root" ] && [ "${PWD:-}" = "/" ]; then
    # We're running as a service, just do the monitoring
    start_monitoring
else
    # We're being run manually, set up the service first
    echo "=== Load Notifier - First Time Setup ==="
    echo "This will set up continuous monitoring of system resources"
    echo "and configure alerts when CPU or memory usage exceeds ${THRESHOLD}%"
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        echo "The 'curl' command is required but not installed."
        echo "Installing curl..."
        
        # Try to detect package manager and install curl
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y curl
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm curl
        else
            echo "Could not automatically install curl. Please install it manually and run this script again."
            exit 1
        fi
    fi
    
    # Setup the service (this will re-invoke the script with sudo if needed)
    setup_service
    
    echo "Setup complete! The monitoring service is now running in the background."
    echo "You can close this terminal window, and the monitoring will continue."
fi
