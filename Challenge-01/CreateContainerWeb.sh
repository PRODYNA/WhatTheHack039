#!/bin/bash

# Create Web container
az container create -n web -g $rg -e "API_URL=http://${sqlapi_ip}:8080" --image "${acr_name}.azurecr.io/hack/web:1.0" --ip-address public --ports 80 \
  --registry-username "$acr_usr" --registry-password "$acr_pwd"
export web_ip=$(az container show -n web -g "$rg" --query ipAddress.ip -o tsv)
echo "Please connect your browser to http://${web_ip} to test the correct deployment"