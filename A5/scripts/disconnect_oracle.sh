#!/bin/bash
# Disconnect from Oracle Database Script

echo "=============================================="
echo "        Oracle Database Disconnection        "
echo "=============================================="

# Check if connected
if [ -f "$CONNECTION_FILE" ]; then
    source "$CONNECTION_FILE"
    echo ""
    echo "Current connection: $ORACLE_USERNAME"
    echo ""
    read -p "Are you sure you want to disconnect? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Remove the connection file
        rm -f "$CONNECTION_FILE"
        echo "Successfully disconnected from Oracle Database"
        echo "Connection credentials cleared."
    else
        echo "Disconnect cancelled."
    fi
else
    echo ""
    echo "No active Oracle database connection found."
fi
