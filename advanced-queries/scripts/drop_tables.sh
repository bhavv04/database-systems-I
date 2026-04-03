#!/bin/bash
# Drop Tables Script

declare QUERY_FILE="queries/drop_tables.sql"

echo "=============================================="
echo "             Drop Database Tables             "
echo "=============================================="

# Check if connected
if [ ! -f "$CONNECTION_FILE" ]; then
    echo ""
    echo "Error: No active connection to Oracle database"
    echo "Please connect to the database first using 'Connect Oracle DB' option"
    exit 1
fi

# Load connection details
source "$CONNECTION_FILE"

echo ""
echo "Current connection: $ORACLE_USERNAME"

TABLE_COUNT=$($SQLPLUS_CMD -S -L "$ORACLE_CONNECTION_STRING" <<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF TRIMOUT ON TRIMSPOOL ON
SELECT COUNT(*) FROM user_tables;
EXIT;
EOF
)

if [ "$TABLE_COUNT" -eq 0 ]; then
    echo ""
    echo "No tables found in the database. Nothing to drop."
    exit 0
fi

# Check if drop_tables.sql exists
if [ ! -f $QUERY_FILE ]; then
    echo ""
    echo "Error: $QUERY_FILE file not found"
    exit 1
fi

echo ""
echo "WARNING: This will permanently delete tables and their data!"
echo ""
read -p "Are you sure you want to continue? (y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Executing $QUERY_FILE..."
    echo "----------------------------------------"
    
    # Execute the SQL file using the saved connection
    $SQLPLUS_CMD -S -L "$ORACLE_CONNECTION_STRING" @$QUERY_FILE
    
    echo "----------------------------------------"
    echo "Drop tables operation completed."
else
    echo ""
    echo "Drop tables operation cancelled."
fi
