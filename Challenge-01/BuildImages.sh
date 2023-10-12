#!/bin/bash

# Build images
az acr build -r "$acr_name" -t hack/sqlapi:1.0 ../Resources/api
az acr build -r "$acr_name" -t hack/web:1.0 ../Resources/web
az acr repository list -n "$acr_name" -o table