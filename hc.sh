#!/bin/bash

# System Health Check Script
echo "-------------------------------"
echo "System Health Check"
echo "-------------------------------"

# CPU Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
echo "CPU Usage: $CPU_USAGE%"

# Memory Usage
MEM_USAGE=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
echo "Memory Usage: $MEM_USAGE"

# Disk Usage
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}')
echo "Disk Usage: $DISK_USAGE"

# Alert if usage is high
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    echo "WARNING: High CPU usage!"
fi
if (( $(echo "${MEM_USAGE%\%} > 80" | bc -l) )); then
    echo "WARNING: High memory usage!"
fi
if (( $(echo "${DISK_USAGE%\%} > 80" | bc -l) )); then
    echo "WARNING: High disk usage!"
fi
