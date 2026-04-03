#!/bin/bash

# Check if .env file exists, create if it doesn't
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    touch .env
else
    set -a
    source .env
    set +a
fi

# Add default Oracle connection settings if not present
if [ -z "$ORACLE_HOST" ]; then
    echo -e "\nORACLE_HOST=oracle.scs.ryerson.ca" >> .env
    export ORACLE_HOST="oracle.scs.ryerson.ca"
fi

if [ -z "$ORACLE_PORT" ]; then
    echo -e "\nORACLE_PORT=1521" >> .env
    export ORACLE_PORT="1521"
fi

if [ -z "$ORACLE_SID" ]; then
    echo -e "\nORACLE_SID=orcl" >> .env
    export ORACLE_SID="orcl"
fi

# Check if ORACLE_USERNAME or ORACLE_PASSWORD are undefined
if [ -z "$ORACLE_USERNAME" ] || [ -z "$ORACLE_PASSWORD" ]; then
    echo "Oracle database credentials are missing."
    echo ""
    read -p "Enter Oracle username: " username
    read -s -p "Enter Oracle password: " password
    echo ""
    echo ""

    echo -e "\nORACLE_USERNAME=$username" >> .env
    echo "ORACLE_PASSWORD=$password" >> .env
fi

# Set Oracle Client Library Directory
if [ -z "$ORACLE_CLIENT_LIB_DIR" ]; then
    echo -e "\nORACLE_CLIENT_LIB_DIR=/tmp/instantclient" >> .env
    ORACLE_CLIENT_LIB_DIR="/tmp/instantclient"
fi

# Install Oracle Instant Client if not present
if [ ! -d "$ORACLE_CLIENT_LIB_DIR" ]; then
    echo "Oracle Instant Client not found."
    
    # Detect architecture (macOS only)
    ARCH=$(uname -m)
    
    # Determine download URL and format based on architecture
    case $ARCH in
        arm64)
            URL="https://download.oracle.com/otn_software/mac/instantclient/233023/instantclient-basiclite-macos.arm64-23.3.0.23.09-2.dmg"
            FORMAT="dmg"
            ARCH_NAME="arm64"
            ;;
        x86_64)
            URL="https://download.oracle.com/otn_software/mac/instantclient/198000/instantclient-basiclite-macos.x64-19.8.0.0.0dbru.zip"
            FORMAT="zip"
            ARCH_NAME="x64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            echo "This script only supports macOS on ARM64 or x86_64"
            exit 1
            ;;
    esac
    
    echo "Downloading Instant Client for MacOS $ARCH_NAME..."
    
    # Create temp directory and save current location
    ORIGINAL_DIR=$(pwd)
    mkdir -p /tmp/oracle_install
    cd /tmp/oracle_install
    
    # Download the instant client
    if command -v curl > /dev/null; then
        curl -s -L -o "instantclient.$FORMAT" "$URL"
    else
        echo "Error: Curl not found."
        echo "Please install it or install installclient manually and set the env variable ORACLE_CLIENT_LIB_DIR."
        exit 1
    fi
    
    # Extract based on format
    if [ "$FORMAT" = "dmg" ]; then
        echo "Mounting DMG..."
        hdiutil attach "instantclient.dmg" -quiet -mountpoint /tmp/oracle_mount
        
        # Find the instantclient folder inside the DMG (e.g., instantclient_23_3)
        INSTANT_CLIENT_FOLDER=$(find /tmp/oracle_mount -type d -name "instantclient*" -maxdepth 2 | head -n 1)
        
        if [ -n "$INSTANT_CLIENT_FOLDER" ]; then
            mkdir -p "$ORACLE_CLIENT_LIB_DIR"
            cp -R "$INSTANT_CLIENT_FOLDER"/* "$ORACLE_CLIENT_LIB_DIR/"
        else
            echo "Error: Could not find instantclient folder in DMG."
            hdiutil detach /tmp/oracle_mount -quiet
            exit 1
        fi
        
        # Unmount the DMG
        hdiutil detach /tmp/oracle_mount -quiet
        
    elif [ "$FORMAT" = "zip" ]; then
        if command -v unzip > /dev/null; then
            unzip -q "instantclient.zip"
            
            # Find the instantclient folder (e.g., instantclient_19_8)
            INSTANT_CLIENT_FOLDER=$(find . -type d -name "instantclient*" -maxdepth 1 | head -n 1)
            
            if [ -n "$INSTANT_CLIENT_FOLDER" ]; then
                mkdir -p "$ORACLE_CLIENT_LIB_DIR"
                cp -R "$INSTANT_CLIENT_FOLDER"/* "$ORACLE_CLIENT_LIB_DIR/"
            else
                echo "Error: Could not find instantclient folder after extraction."
                exit 1
            fi
        else
            echo "Error: unzip not found. Please install unzip."
            exit 1
        fi
    fi
    
    # Cleanup
    rm -rf /tmp/oracle_install /tmp/oracle_mount 2>/dev/null
    
    # Return to original directory
    cd "$ORIGINAL_DIR"
    
    echo "Oracle Instant Client installed to: $ORACLE_CLIENT_LIB_DIR"
    echo ""
fi

# Cleanup .env file - remove blank lines
if [ -f ".env" ]; then
    # Remove all blank lines (including ones with spaces)
    sed '/^[[:space:]]*$/d' .env > .env.tmp && mv .env.tmp .env
fi


# Check for Python virtual environment
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    if command -v python3 > /dev/null; then
        python3 -m venv venv
        echo "Virtual environment created!"
        echo ""
    else
        echo "Error: python3 not found. Please install Python 3."
        exit 1
    fi
fi

echo "Activating virtual environment and installing dependencies..."
source venv/bin/activate
pip -q install --upgrade pip && pip -q install -r requirements.txt

echo "Starting the application..."
echo ""
echo "Open your browser to: http://127.0.0.1:5000"
echo ""
python app/app.py
