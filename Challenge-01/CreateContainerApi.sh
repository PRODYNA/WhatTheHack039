#!/bin/bash

# Create API container
export aci_name=sqlapi
export acr_usr=$(az acr credential show -n "$acr_name" -g "$rg" --query 'username' -o tsv)
export acr_pwd=$(az acr credential show -n "$acr_name" -g "$rg" --query 'passwords[0].value' -o tsv)
az container create -n "$aci_name" -g $rg  -e "SQL_SERVER_USERNAME=${sql_username}" "SQL_SERVER_PASSWORD=${sql_password}" "SQL_SERVER_FQDN=${sql_server_fqdn}" \
    --image "${acr_name}.azurecr.io/hack/sqlapi:1.0" --ip-address public --ports 8080 \
    --registry-username "$acr_usr" --registry-password "$acr_pwd"
export sqlapi_ip=$(az container show -n "$aci_name" -g "$rg" --query ipAddress.ip -o tsv)
export sqlapi_source_ip=$(curl -s "http://${sqlapi_ip}:8080/api/ip" | jq -r .my_public_ip)
az sql server firewall-rule create -g "$rg" -s "$sql_server_name" -n public_sqlapi_aci-source --start-ip-address "$sqlapi_source_ip" --end-ip-address "$sqlapi_source_ip"
curl "http://${sqlapi_ip}:8080/api/healthcheck"
curl "http://${sqlapi_ip}:8080/api/sqlsrcip"
echo "The output of the previous command should have been ${sqlapi_source_ip}"