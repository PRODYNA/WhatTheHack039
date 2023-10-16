# WhatTheHack039

This project contains the reference solutin.

## Requirements

* Azure subscription
* Contributor permissions on this subscription
* The following tools
  * az (Azure CLI)
  * terraform
  * kubectl
  * helm
  * kubelogin

## Installation

The infrastructure is defined in Terraform, a descriptive Infrastructure-as-Code technology. The infrastructure is provisioned in two stages

* Azure
* Kubernetes

Azure contains the whole Azure parts and includes a Azure Kubernetes Service (AKS). The second stage provisions resources in the AKS.

### Install the Azure part

Go to the Azure directory. Login to Azure, either

```shell
az login
```

for human login or

```shell
az login --service-principal -u <username> -p <password>
```

in case you have a service principal. Then run

```shell
terraform init
```

to install all Terraform providers and modules. After that create the infrastructure running

```shell
terraform apply
```

Terraform will create a plan that you can confirm by typing "yes" upon question.

### Install the Kubernetes part

Go to the Kubernetes directory. Run

```shell
terraform init
```

and then

```shell
terraform apply
```

again, confirm with "yes" when asked.

### Tearing down

Run the command

```shell
terraform destroy
```

first in the Kubernetes, then Azure parts (reverse order)
