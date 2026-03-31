#!/bin/bash
# Advanced Queries Script

QUERY_FILE="queries/advanced_queries.sql"

echo "=============================================="
echo "            Run Advanced Queries              "
echo "=============================================="

# Check if connected
if [ ! -f "$CONNECTION_FILE" ]; then
    echo ""
    echo "Error: No active connection to Oracle database"
    echo "Please connect first using 'connect_oracle.sh'"
    echo ""
    read -s -p "Press Enter to continue..."
    exit 1
fi

# Check if SQL file exists
if [ ! -f "$QUERY_FILE" ]; then
    echo ""
    echo "Error: $QUERY_FILE file not found"
    echo ""
    read -s -p "Press Enter to continue..."
    exit 1
fi

# Load connection details
source "$CONNECTION_FILE"

echo ""
echo "Current connection: $ORACLE_USERNAME"

# Extract query descriptions
get_queries() {
    grep "^-- " "$QUERY_FILE" | sed 's/^-- //'
}

# Extract specific query by description
get_query() {
    local desc="$1"
    local start=$(grep -n "^-- $desc" "$QUERY_FILE" | cut -d: -f1)
    local end=$(tail -n +$((start + 1)) "$QUERY_FILE" | grep -n "^--\|^exit;" | head -1 | cut -d: -f1)
    
    [ -z "$end" ] && end=$(wc -l < "$QUERY_FILE") || end=$((start + end - 1))
    sed -n "$((start + 1)),$((end - 1))p" "$QUERY_FILE" | sed '/^$/d;/^exit;/d'
}

# Execute custom query
custom_query() {
    local temp="/tmp/query_$$.sql"
    
    cat > "$temp" << 'EOF'
-- Write your SQL query below:

EOF
    
    echo "Opening editor..."
    tput cnorm
    "${EDITOR:-vim}" "$temp"
    tput civis
    
    if grep -q -v "^--\|^$" "$temp"; then
        clear
        echo "Executing query..."
        echo "----------------------------------------"
        
        # Pipe formatted content directly to SQLPlus
        {
            echo "-- SQL*Plus formatting commands"
            echo "SET PAGESIZE 50"
            echo "SET LINESIZE 300"
            echo "SET COLSEP ' | '"
            echo "SET WRAP OFF"
            echo "SET TRIMOUT ON"
            echo "SET TRIMSPOOL ON"
            echo "SET FEEDBACK OFF"
            echo "SET HEADING ON"
            echo "SET NUMWIDTH 15"
            echo "SET TRANSACTION READ ONLY;"
            echo ""
            cat "$temp"
            echo "exit;"
        } | $SQLPLUS_CMD -S -L "$ORACLE_CONNECTION_STRING"
        
        echo ""
        echo "----------------------------------------"
    else
        clear
        echo "No query entered."
    fi
    
    rm -f "$temp"
    read -p "Press Enter to continue..."
}

# Run predefined query
run_query() {
    local desc="$1"
    local temp="/tmp/predefined_query_$$.sql"
    
    # Create temp file with formatting commands and query
    cat > "$temp" << EOF
-- SQL*Plus formatting commands
SET PAGESIZE 50
SET LINESIZE 300
SET COLSEP ' | '
SET WRAP OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET FEEDBACK OFF
SET HEADING ON
SET NUMWIDTH 15

$(get_query "$desc")

exit;
EOF
    
    clear
    echo "Executing: $desc"
    echo "----------------------------------------"
    $SQLPLUS_CMD -S -L "$ORACLE_CONNECTION_STRING" @"$temp"
    echo ""
    echo "----------------------------------------"
    
    rm -f "$temp"
    read -p "Press Enter to continue..."
}

# Main menu
show_menu() {
    local queries=()
    local current=0
    
    # Build menu array
    while IFS= read -r line; do
        queries+=("$line")
    done < <(get_queries)
    
    queries+=("" "Custom Query" "" "Exit")
    local total=${#queries[@]}
    
    while true; do
        clear
        echo "=============================================="
        echo "         Select Query to Execute             "
        echo "=============================================="
        echo ""
        echo "Use arrow keys to navigate, Enter to select:"
        echo ""
        
        # Display menu
        for i in "${!queries[@]}"; do
            if [ $i -eq $current ]; then
                echo "> ${queries[$i]}"
            else
                echo "  ${queries[$i]}"
            fi
        done
        
        # Handle input
        read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key
            case $key in
                '[A')
                    if [ $current -gt 0 ]; then
                        ((current--))
                    fi
                    ;;
                '[B')
                    if [ $current -lt $((total - 1)) ]; then
                        ((current++))
                    fi
                    ;;
            esac
        elif [[ $key == "" ]]; then
            local selected="${queries[$current]}"
            
            case "$selected" in
                "") continue ;;
                "Exit") exit 0 ;;
                "Custom Query") custom_query ;;
                *) run_query "$selected" ;;
            esac
        elif [[ $key == "q" || $key == "Q" ]]; then
            exit 0
        fi
    done
}

# Start the menu
show_menu
