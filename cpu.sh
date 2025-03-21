#!/bin/bash

MAX=85
EMAIL="ashwinbshetty373@gmail.com"

# Get CPU usage over 1 second interval
USE=$(awk -v FS=" " '{u=$2+$4; t=$2+$4+$5} NR==1 {u1=u; t1=t} NR==2 {print (u-u1)*100/(t-t1)}' <(head -n1 /proc/stat; sleep 1; head -n1 /proc/stat))

# Convert MAX to floating point for comparison
if (( $(echo "$USE > $MAX" | bc -l) )); then
    echo "Percent used: $USE%" | mail -s "Running out of CPU power" "$EMAIL"
fi
