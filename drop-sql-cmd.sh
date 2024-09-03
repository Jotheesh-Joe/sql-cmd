#!/bin/bash

if [ -z "$server" ] || [ -z "$databases" ]; then
    echo "One or more required environment variables are not set. Please ensure 'server' and 'databases' are set."
    exit 1
fi

# Define the list of databases
IFS=',' read -r -a database_array <<< "$databases"

# AZ login with workload identity
az login --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)" --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID

TOKEN="/tmp/token"  # Replace this with your actual token or ensure it's set in the environment

# Extracting Access Token
az account get-access-token --resource https://database.windows.net --output tsv | cut -f 1 | tr -d '\n' | iconv -f ascii -t UTF-16LE > "$TOKEN"

# Loop through each database and run the sqlcmd command
for db in "${database_array[@]}"; do
    echo "Processing database: $db"

    if [[ "$db" == order_* ]]; then
        echo "Running additional command for database: $db"
		sqlcmd -S "$server" -d "$db" -G -P "$TOKEN" -Q "DROP TABLE dbo.voucher;"
		exit_status=$?  # Capture the exit status
		if [ $exit_status -ne 0 ]; then
            echo "Error occurred while processing table dbo.voucher in database: $db"
        else
            echo "Successfully processed dbo.voucher table in database: $db"
        fi
    fi

    # Run the sqlcmd command for the first table
    sqlcmd -S "$server" -d "$db" -G -P "$TOKEN" -Q "DROP TABLE dbo.socrates_store_database;"
    exit_status1=$?  # Capture the exit status
    if [ $exit_status1 -ne 0 ]; then
        echo "Error occurred while processing table dbo.socrates_database_server in database: $db"
    else
        echo "Successfully processed dbo.socrates_store_database table in database: $db"
    fi

    # Run the sqlcmd command for the second table
    sqlcmd -S "$server" -d "$db" -G -P "$TOKEN" -Q "DROP TABLE dbo.socrates_database_server;"
    exit_status2=$?  # Capture the exit status
    if [ $exit_status2 -ne 0 ]; then
        echo "Error occurred while processing table dbo.socrates_database_server in database: $db"
    else
        echo "Successfully processed dbo.socrates_database_server table in database: $db"
    fi
done
