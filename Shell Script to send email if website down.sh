#!/bin/bash

# Prompt the user for input
read -p "Enter your email: " sender
read -p "Enter recipient email: " receiver
read -s -p "Enter your Google App password: " gapp
echo

# List of URLs to check
urls=("https://www.example.com" "https://www.google.com" "https://www.openai.com")

# Function to check the status of URLs and send email notification if any are down
check_urls_and_send_email() {
    local down_urls=""
    local subject="Website Down"
    for url in "${urls[@]}"; do
        response=$(curl -Is "$url" | head -n 1)
        if [[ ! $response =~ "200" ]]; then
            down_urls+="$url\n"
        fi
    done
    if [[ -n $down_urls ]]; then
        body="The following websites are down:\n\n$down_urls"
        email_content="From: $sender\nTo: $receiver\nSubject: $subject\n\n$body"
        response=$(curl -s --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
            --mail-from "$sender" \
            --mail-rcpt "$receiver" \
            --user "$sender:$gapp" \
            -T <(echo -e "$email_content"))
        if [ $? -eq 0 ]; then
            echo "Email sent successfully."
        else
            echo "Failed to send email."
            echo "Response: $response"
        fi
    else
        echo "All websites are up."
    fi
}

# Call the function to check URLs and send email
check_urls_and_send_email