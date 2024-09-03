#!/bin/bash

if [ -z "$server" ] || [ -z "$databases" ]; then
    echo "One or more required environment variables are not set. Please ensure 'server' and 'databases' are set."
    exit 1
fi

# Define the list of databases
IFS=',' read -r -a database_array <<< "$databases"

# Extracting Access Token
az login --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)" --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID

TOKEN="/tmp/token"  # Replace this with your actual token or ensure it's set in the environment

# Loop through each database and run the sqlcmd command
for db in "${database_array[@]}"; do
    echo "Processing database: $db"

    if [[ "$db" == "order_microservice_ie_mo0" ]]; then
        echo "Running additional command for database: $db"
		sqlcmd -S "$server" -d "$db" -G -P "$TOKEN" -Q "CREATE TABLE dbo.voucher (id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, external_reference VARCHAR(255), amount BIGINT, description VARCHAR(255), basket_id UNIQUEIDENTIFIER NOT NULL);"
		exit_status=$?  # Capture the exit status
		if [ $exit_status -ne 0 ]; then
            echo "Error occurred while processing table dbo.voucher in database: $db"
        else
            echo "Successfully processed dbo.voucher table in database: $db"
        fi
    fi

    # Run the sqlcmd command for the dbo.socrates_database_server table
    sqlcmd -S "$server" -d "$db" -G -P "$TOKEN" -Q "CREATE TABLE dbo.socrates_database_server (server VARCHAR(50) NOT NULL PRIMARY KEY, username VARCHAR(50) NOT NULL, password VARCHAR(50) NOT NULL);"
    exit_status2=$?  # Capture the exit status
    if [ $exit_status2 -ne 0 ]; then
        echo "Error occurred while processing table dbo.socrates_database_server in database: $db"
    else
        echo "Successfully processed dbo.socrates_database_server table in database: $db"
    fi

    # Run the sqlcmd command for the dbo.socrates_store_database table
    sqlcmd -S "$server" -d "$db" -G -P "$TOKEN" -Q "CREATE TABLE dbo.socrates_store_database (store_id VARCHAR(50) NOT NULL PRIMARY KEY, database_server VARCHAR(50) NOT NULL, database_schema VARCHAR(50) NOT NULL, CONSTRAINT fk_database_server FOREIGN KEY (database_server) REFERENCES dbo.socrates_database_server(server));"
    exit_status1=$?  # Capture the exit status
    if [ $exit_status1 -ne 0 ]; then
        echo "Error occurred while processing table dbo.socrates_database_server in database: $db"
    else
        echo "Successfully processed dbo.socrates_store_database table in database: $db"
    fi

done
