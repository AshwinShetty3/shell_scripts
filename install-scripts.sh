#!/bin/bash

# Prompt the user for the Git repository URL
read -p "🔗 Enter the Git repository URL (HTTPS): " GIT_REPO

# Validate the input
if [[ -z "$GIT_REPO" ]]; then
    echo "❌ Error: Git repository URL cannot be empty."
    exit 1
fi

# Variables
TEMP_DIR="/tmp/scripts"                                   # Temporary directory to clone the repo
TARGET_DIR="/usr/local/bin"                               # Target directory for scripts

# Step 1: Clone the Git repository
echo "⛓️‍💥 Cloning Git repository: $GIT_REPO"
if ! git clone "$GIT_REPO" "$TEMP_DIR"; then
    echo "❌ Error: Failed to clone the Git repository. Please check the URL and try again."
    exit 1
fi

# Step 2: Check for existing files and prompt for overwrite
echo "🤨 Checking for existing scripts in $TARGET_DIR..."
for script in "$TEMP_DIR"/*.sh; do
    script_name=$(basename "$script")
    if [[ -f "$TARGET_DIR/$script_name" ]]; then
        echo "🧐 File $script_name already exists in $TARGET_DIR."
        read -p "Do you want to overwrite it? (yes/no/y/n): " overwrite
        case $overwrite in
            [yY]|[yY][eE][sS])
                sudo mv "$script" "$TARGET_DIR/"
                echo "✅ Overwritten $script_name in $TARGET_DIR."
                ;;
            [nN]|[nN][oO])
                echo "⏩ Skipping $script_name."
                ;;
            *)
                echo "❓ Invalid input. Skipping $script_name."
                ;;
        esac
    else
        sudo mv "$script" "$TARGET_DIR/"
        echo "🚀 Moved $script_name to $TARGET_DIR."
    fi
done

# Step 3: Make all scripts executable
echo "🔧 Making scripts executable..."
for script in "$TARGET_DIR"/*.sh; do
    sudo chmod +x "$script"
    echo "🔨 Made executable: $script"
done

# Step 4: Clean up
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "✅ All scripts have been installed and made executable!"
