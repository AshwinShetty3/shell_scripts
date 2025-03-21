#!/bin/bash
echo "System Load: $(uptime)"
echo "Free Memory: $(free -h | grep Mem | awk '{print $4}')"
echo "Free Disk Space: $(df -h / | grep / | awk '{print $4}')"
