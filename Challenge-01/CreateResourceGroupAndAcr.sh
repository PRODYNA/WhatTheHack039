# Create RG and ACR
export rg=hack$RANDOM
acr_name=$rg
export location=westeurope
az group create -n "$rg" -l "$location"
az acr create -n "$acr_name" -g "$rg" --sku Standard
az acr update -n "$acr_name" --admin-enabled true