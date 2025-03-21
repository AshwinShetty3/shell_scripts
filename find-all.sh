#!/bin/bash

# Prompt the user for search criteria
read -p "Enter the name to search: " name
read -p "Search for (f=file, d=directory, a=all): " type

# Define search pattern to match any file or directory with the given prefix
search_pattern="$name*"

# Determine search type and corresponding message
case "$type" in
    f) search_cmd="find / -type f -iname '$search_pattern' 2>/dev/null"
       msg="There is no file named '$name'" ;;
    d) search_cmd="find / -type d -iname '$search_pattern' 2>/dev/null"
       msg="There is no directory named '$name'" ;;
    a) search_cmd="find / -iname '$search_pattern' 2>/dev/null"
       msg="There is no file or directory named '$name'" ;;
    *) echo "Invalid choice. Searching for all types by default."
       search_cmd="find / -iname '$search_pattern' 2>/dev/null"
       msg="There is no file or directory named '$name'" ;;
esac

# Execute search and display results with line numbers
results=$(eval $search_cmd)
if [ -z "$results" ]; then
    echo "$msg"
else
    echo "$results" | nl -w2 -s". "
fi

