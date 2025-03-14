#!/usr/bin/env bash

# Formspree Email Configuration
FORMSPREE_ENDPOINT="https://formspree.io/f/mpwzekgg"
TO_EMAIL="ashwinbshetty373@gmail.com"

# Function to send email notification via Formspree
send_email() {
    local subject="$1"
    local message="$2"

    curl -s -X POST "$FORMSPREE_ENDPOINT" \
         -H "Content-Type: application/json" \
         -d @- <<EOF
{
  "email": "$TO_EMAIL",
  "subject": "$subject",
  "message": "$message"
}
EOF

    echo "📧 Email notification sent successfully."
}

# Function to display the main menu
menuprincipal() {
    clear
    echo "==============================="
    echo "   🔒 File & Folder Encryptor  "
    echo "==============================="
    echo "1) Encrypt a File"
    echo "2) Encrypt a Folder"
    echo "3) Decrypt a File"
    echo "4) Decrypt a Folder"
    echo "0) Exit"
    echo "-------------------------------"
    read -p "Select an option: " opcao

    case $opcao in
        1) encrypt_file ;;
        2) encrypt_folder ;;
        3) decrypt_file ;;
        4) decrypt_folder ;;
        0) exit 0 ;;
        *) echo "Invalid option, try again!" ;;
    esac
    read -n 1 -s -r -p "<Enter> to return to the main menu"
    menuprincipal
}

# Function to encrypt a file
encrypt_file() {
    read -p "Enter the filename (without extension) to encrypt: " filename
    read -p "Enter the file extension (e.g., txt, sh) [Default: txt]: " extension
    [[ -z "$extension" ]] && extension="txt"

    file="${filename}.${extension}"

    if [[ ! -f "$file" ]]; then
        echo "⚠️ File '$file' not found."
        read -p "Do you want to create a new file? (y/n): " create
        if [[ "$create" == "y" ]]; then
            touch "$file"
            echo "New empty file '$file' created. You can now add content."
        else
            echo "❌ Operation cancelled."
            return
        fi
    fi

    # Ask for password securely
    while true; do
        read -s -p "Enter a password for encryption: " password
        echo ""
        read -s -p "Re-enter password to confirm: " password_confirm
        echo ""

        if [[ "$password" == "$password_confirm" ]]; then
            break
        else
            echo "❌ Error: Passwords do not match! Please try again."
        fi
    done

    # Encrypt file with password
    echo "$password" | gpg --batch --passphrase-fd 0 -c "$file"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ File encrypted successfully: $file.gpg"
        
        # Send email with password
        email_message="File name (encrypted) - $file.gpg
Password - $password"
        send_email "Your Encryption Password" "$email_message"
        
        echo "📧 Password has been shared to the registered mail."
    else
        echo "❌ Encryption failed!"
        return
    fi

    # Delete original file
    read -p "Do you want to delete the original file? (y/n): " delete
    [[ "$delete" == "y" ]] && rm -rf "$file" && echo "🗑 Original file deleted."
}

# Function to encrypt a folder
encrypt_folder() {
    read -p "Enter the folder name to encrypt: " folder

    if [[ ! -d "$folder" ]]; then
        echo "⚠️ Folder '$folder' not found."
        read -p "Do you want to create a new folder? (y/n): " create
        if [[ "$create" == "y" ]]; then
            mkdir -p "$folder"
            echo "New empty folder '$folder' created. You can now add files."
        else
            echo "❌ Operation cancelled."
            return
        fi
    fi

    tar -czf "$folder.tar.gz" "$folder"

    # Ask for password securely
    while true; do
        read -s -p "Enter a password for encryption: " password
        echo ""
        read -s -p "Re-enter password to confirm: " password_confirm
        echo ""

        if [[ "$password" == "$password_confirm" ]]; then
            break
        else
            echo "❌ Error: Passwords do not match! Please try again."
        fi
    done

    # Encrypt folder with password
    echo "$password" | gpg --batch --passphrase-fd 0 -c "$folder.tar.gz"

    if [[ $? -eq 0 ]]; then
        echo "✅ Folder encrypted successfully: $folder.tar.gz.gpg"
        
        # Send email with password
        email_message="Folder name (encrypted) - $folder.tar.gz.gpg
Password - $password"
        send_email "Your Encryption Password" "$email_message"
        
        echo "📧 Password has been shared to the registered mail."
    else
        echo "❌ Encryption failed!"
        return
    fi

    # Delete original folder and archive
    read -p "Do you want to delete the original folder and archive? (y/n): " delete
    [[ "$delete" == "y" ]] && rm -rf "$folder" "$folder.tar.gz" && echo "🗑 Original folder deleted."
}

# Function to decrypt a file
decrypt_file() {
    read -p "Enter the encrypted filename (with .gpg extension) to decrypt: " encfile

    if [[ ! -f "$encfile" ]]; then
        echo "❌ Error: Encrypted file '$encfile' not found!"
        return
    fi

    output_file="${encfile%.gpg}"  # Remove .gpg to get original filename

    # Ask for password securely
    read -s -p "Enter the password to decrypt: " password
    echo ""

    # Decrypt file with password
    echo "$password" | gpg --batch --passphrase-fd 0 -d "$encfile" > "$output_file" 2>/dev/null

    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Incorrect password! Decryption failed."
        echo "🔑 Password was shared in registered mail on creation."
        rm -f "$output_file" 
        return
    fi

    echo "✅ File decrypted successfully: $output_file"
}

# Function to decrypt a folder
decrypt_folder() {
    read -p "Enter the encrypted folder name (without .tar.gz.gpg extension): " folder

    enc_folder="${folder}.tar.gz.gpg"
    archive_file="${folder}.tar.gz"

    if [[ ! -f "$enc_folder" ]]; then
        echo "❌ Error: Encrypted archive '$enc_folder' not found!"
        return
    fi

    # Ask for password securely
    read -s -p "Enter the password to decrypt: " password
    echo ""

    # Decrypt folder with password
    echo "$password" | gpg --batch --passphrase-fd 0 -d "$enc_folder" > "$archive_file" 2>/dev/null

    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Incorrect password! Decryption failed."
        echo "🔑 Password was shared in registered mail on creation."
        rm -f "$archive_file"
        return
    fi

    tar -xzf "$archive_file"
    echo "✅ Folder decrypted successfully: $folder"
}

# Run the menu
menuprincipal

