#!/bin/bash

# Ask the user for the name to search
read -p "Enter the name to search: " name

# Ask the user for the type (file or directory)
read -p "Search for (f=file, d=directory, a=all): " type

# Set find type filter
case "$type" in
    f) results=$(find / -type f -iname "$name" 2>/dev/null)
       msg="There is no file of name '$name'" ;;
    d) results=$(find / -type d -iname "$name" 2>/dev/null)
       msg="There is no directory of name '$name'" ;;
    a) results=$(find / -iname "$name" 2>/dev/null)
       msg="There is no file or directory of name '$name'" ;;
    *) echo "Invalid choice, searching for all types by default."
       results=$(find / -iname "$name" 2>/dev/null)
       msg="There is no file or directory of name '$name'" ;;
esac

# Check if results are empty
if [ -z "$results" ]; then
    echo "$msg"
else
    echo "$results" | nl -w2 -s". "
fi

