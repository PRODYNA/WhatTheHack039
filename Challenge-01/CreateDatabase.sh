#!/bin/bash

export sql_server_name=sqlserver$RANDOM
export sql_db_name=mydb
export sql_username=azure
export sql_password=Microsoft123!
az sql server create -n "$sql_server_name" -g "$rg" -l "$location" --admin-user "$sql_username" --admin-password "$sql_password"
export sql_server_fqdn=$(az sql server show -n "$sql_server_name" -g "$rg" -o tsv --query fullyQualifiedDomainName)
az sql db create -n "$sql_db_name" -s "$sql_server_name" -g "$rg" -e Basic -c 5 --no-wait