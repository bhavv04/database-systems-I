#!/bin/bash
# Create Tables Script

declare QUERY_FILE="queries/populate_tables.sql"

echo "=============================================="
echo "           Populate Database Tables           "
echo "=============================================="

# Check if connected
if [ ! -f "$CONNECTION_FILE" ]; then
    echo ""
    echo "Error: No active connection to Oracle database"
    echo "Please connect to the database first using 'Connect Oracle DB' option"
    exit 1
fi

# Check if create_tables.sql exists
if [ ! -f $QUERY_FILE ]; then
    echo ""
    echo "Error: $QUERY_FILE file not found"
    exit 1
fi

# Load connection details
source "$CONNECTION_FILE"

echo ""
echo "Current connection: $ORACLE_USERNAME"
echo ""
read -p "Populate tables? (y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Executing $QUERY_FILE..."
    echo "----------------------------------------"
    
    # Execute the SQL file using the saved connection
    $SQLPLUS_CMD -S -L "$ORACLE_CONNECTION_STRING" @$QUERY_FILE
    
    echo "----------------------------------------"
    echo "Populate tables operation completed."
else
    echo ""
    echo "Populate tables operation cancelled."
fi
