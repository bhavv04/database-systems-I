#!/bin/bash
# Connect to Oracle Database Script

declare QUERY_FILE="/queries/test_connection.sql"

echo "=============================================="
echo "          Oracle Database Connection          "
echo "=============================================="

# Check if already connected
if [ -f "$CONNECTION_FILE" ]; then
    source "$CONNECTION_FILE"
    echo ""
    echo "Already connected as: $ORACLE_USERNAME"
    echo ""
    read -p "Do you want to disconnect and create a new connection? (y/N): " reconnect
    if [[ ! "$reconnect" =~ ^[Yy]$ ]]; then
        echo "Keeping existing connection."
        echo ""
        exit 0
    fi
    echo "Creating new connection..."
fi

echo ""
echo "Please enter your Oracle database credentials:"
echo ""

# Get credentials from user
read -p "Username: " username
read -s -p "Password (MMDDXXXX): " password
echo ""

# Build connection string with password
CONNECTION_STRING="$username/$password@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle.scs.ryerson.ca)(PORT=1521))(CONNECT_DATA=(SID=orcl)))"

echo ""
echo "Testing connection to Oracle database..."

# Test connection by running the test SQL file
TEST_OUTPUT=$(echo "SELECT 'CONNECTION_SUCCESS' FROM dual; EXIT;" | $SQLPLUS_CMD -S -L "$CONNECTION_STRING" 2>&1)


# Check if we got the success marker
if echo "$TEST_OUTPUT" | grep -iq "CONNECTION_SUCCESS"; then
    # Save credentials for other scripts to use
    cat > "$CONNECTION_FILE" << EOF
ORACLE_USERNAME="$username"
ORACLE_PASSWORD="$password"
ORACLE_CONNECTION_STRING="$CONNECTION_STRING"
CONNECTION_ACTIVE=true
EOF
    chmod 600 "$CONNECTION_FILE"  # Secure the file

    echo "Successfully connected to Oracle Database!"
    echo "Connection saved for this session."
    echo ""
    echo "Connected as: $username"
else
    echo "Connection failed!"
    echo ""
    echo "Please check your credentials and try again."
fi
