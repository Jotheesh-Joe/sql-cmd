#!/bin/bash

# Check if the ACTION environment variable is set
if [ -z "$ACTION" ]; then
    echo "ACTION environment variable is not set. Please set ACTION to 'Create' or 'Delete'."
    exit 1
fi

# Call the appropriate script based on the value of ACTION
if [ "$ACTION" == "Create" ]; then
    echo "Running create-sql-cmd.sh"
    /usr/local/bin/create-sql-cmd.sh
    exit_status=$?
    if [ $exit_status -ne 0 ]; then
        echo "Error occurred while running create-sql-cmd.sh"
        exit $exit_status
    fi

elif [ "$ACTION" == "Delete" ]; then
    echo "Running drop-sql-cmd.sh"
    /usr/local/bin/drop-sql-cmd.sh
    exit_status=$?
    if [ $exit_status -ne 0 ]; then
        echo "Error occurred while running drop-sql-cmd.sh"
        exit $exit_status
    fi

else
    echo "Invalid ACTION value. Set ACTION to 'Create' or 'Delete'."
    exit 1
fi
