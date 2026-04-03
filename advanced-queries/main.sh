#!/bin/bash
# filepath: /Users/parsa/Developer/Databases/CPS510/A5/main.sh

# Initialize variables
declare -i SELECTED=0
declare -a MENU_OPTIONS=("View Manual" "" "Connect Oracle DB" "Disconnect Oracle DB" "" "Drop Tables" "Create Tables" "Populate Tables" "Query Tables" "" "End/Exit")
declare -i MENU_COUNT=${#MENU_OPTIONS[@]}

# Determine which sqlplus command to use
if command -v sqlplus64 >/dev/null 2>&1; then
    export SQLPLUS_CMD="sqlplus64"
elif command -v sqlplus >/dev/null 2>&1; then
    export SQLPLUS_CMD="sqlplus"
else
    echo "Error: Neither sqlplus nor sqlplus64 found in PATH"
    exit 1
fi

# Connection details file
export CONNECTION_FILE=".oracle_connection"

StartMessage() {
    echo "Welcome to Oracle All Inclusive Tool"
    echo "Starting program..."
    sleep 1
}

# Function to hide cursor
hide_cursor() {
    printf '\033[?25l'
}

# Function to show cursor
show_cursor() {
    printf '\033[?25h'
}

clear_screen() {
    clear
}


draw_menu() {
    clear_screen
    echo "================================================================="
    echo "|                   Oracle All Inclusive Tool                   |"
    echo "|            Main Menu - Select Desired Operation(s):           |"
    echo "================================================================="
    echo ""
    
    for ((i=0; i<MENU_COUNT; i++)); do
        if [ $i -eq $SELECTED ]; then
            printf "  > %s\n" "${MENU_OPTIONS[$i]}"
        else
            printf "    %s\n" "${MENU_OPTIONS[$i]}"
        fi
    done
    
    echo ""
    echo "Use up/down arrow keys to navigate, Enter to select, q to quit"
}

read_key() {
    local key
    read -s -n1 key
    
    # Handle escape sequences for arrow keys
    if [[ $key == $'\033' ]]; then
        read -s -n2 key
        case $key in
            '[A') echo "UP" ;;
            '[B') echo "DOWN" ;;
        esac
    else
        case $key in
            'q'|'Q') echo "QUIT" ;;
            '') echo "ENTER" ;;
        esac
    fi
}

execute_option() {
    local selected_option="${MENU_OPTIONS[$SELECTED]}"

    case "$selected_option" in
        "View Manual")
            clear_screen
            if [ -f "scripts/manual.txt" ]; then
                cat scripts/manual.txt
            else
                echo "Manual/Help content would go here"
            fi
            echo ""
            read -s -p "Press Enter to continue..."
            ;;
        "Connect Oracle DB")
            clear_screen
            if [ -f "scripts/connect_oracle.sh" ]; then
                bash scripts/connect_oracle.sh
            else
                echo "Error: scripts/connect_oracle.sh not found"
            fi
            echo ""
            read -s -p "Press Enter to continue..."
            ;;
        "Disconnect Oracle DB")
            clear_screen
            if [ -f "scripts/disconnect_oracle.sh" ]; then
                bash scripts/disconnect_oracle.sh
            else
                echo "Error: scripts/disconnect_oracle.sh not found"
            fi
            echo ""
            read -s -p "Press Enter to continue..."
            ;;
        "Drop Tables")
            clear_screen
            if [ -f "scripts/drop_tables.sh" ]; then
                bash scripts/drop_tables.sh
            else
                echo "Error: scripts/drop_tables.sh not found"
            fi
            echo ""
            read -s -p "Press Enter to continue..."
            ;;
        "Create Tables")
            clear_screen
            if [ -f "scripts/create_tables.sh" ]; then
                bash scripts/create_tables.sh
            else
                echo "Error: scripts/create_tables.sh not found"
            fi
            echo ""
            read -s -p "Press Enter to continue..."
            ;;
        "Populate Tables")
            clear_screen
            if [ -f "scripts/populate_tables.sh" ]; then
                bash scripts/populate_tables.sh
            else
                echo "Error: scripts/populate_tables.sh not found"
            fi
            echo ""
            read -s -p "Press Enter to continue..."
            ;;
        "Query Tables")
            clear_screen
            if [ -f "scripts/advanced_queries.sh" ]; then
                bash scripts/advanced_queries.sh
            else
                echo "Error: scripts/advanced_queries.sh not found"
                echo ""
                read -s -p "Press Enter to continue..."
            fi
            ;;
        "End/Exit")
            echo "Exiting..."
            rm -f "$CONNECTION_FILE"
            show_cursor
            exit 0
            ;;
    esac
}

MainMenu() {
    hide_cursor
    trap 'show_cursor; rm -f "$CONNECTION_FILE"; exit' INT TERM
    
    while true; do
        draw_menu
        
        key=$(read_key)
        
        case $key in
            "UP")
                if [ $SELECTED -gt 0 ]; then
                    SELECTED=$((SELECTED - 1))
                else
                    SELECTED=$((MENU_COUNT - 1))
                fi
                ;;
            "DOWN")
                if [ $SELECTED -lt $((MENU_COUNT - 1)) ]; then
                    SELECTED=$((SELECTED + 1))
                else
                    SELECTED=0
                fi
                ;;
            "ENTER")
                execute_option
                ;;
            "QUIT")
                echo "Exiting..."
                rm -f "$CONNECTION_FILE"
                show_cursor
                exit 0
                ;;
        esac
    done
}

ProgramStart() {
    StartMessage
    MainMenu
}

ProgramStart