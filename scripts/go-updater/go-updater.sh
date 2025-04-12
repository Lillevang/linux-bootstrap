#!/bin/bash

# Fetch the current version of the Go binary
installed_version=$(go version | awk '{print $3}' | sed 's/^..//')

# Call the python script with the installed version as argument TODO: make the path to the script configurable somehow...
output=$(python3 ~/util/go-updater/check_go_update.py $installed_version)

read version download_link checksum <<<$(echo $output)

# if version is empty, then the installed version is the latest
if [ -z "$version" ]; then
    echo "Go is up to date"
    exit 0
fi

if [ -n "$version" ]; then
    echo "New version available: $version"

    # Download the new version
    wget -O go_new_version.tar.gz $download_link

    # Verify the checksum
    echo "$checksum go_new_version.tar.gz" | sha256sum -c -

    # If the checksum is correct, install the new version
    if [ $? -eq 0 ]; then
        echo "New version valid, updating Go..."
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf go_new_version.tar.gz
        rm go_new_version.tar.gz
        echo "Go updated to version $version"
    else
        echo "Checksum verification failed."
        rm go_new_version.tar.gz
    fi
fi
