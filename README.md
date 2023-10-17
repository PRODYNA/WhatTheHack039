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

in case you have a service principal. Switch to the right subscription using

```shell
az account set --subscription <subscription-id>
```

And then run

```shell
terraform init
```

to install all Terraform providers and modules. After that create the infrastructure running

```shell
terraform apply
```

Terraform will create a plan that you can confirm by typing "yes" upon question. You will find the following resource groups in the subscription

* hack<random>XXXX
* hackXXXX-aks-resources

![image.png](assets/resourcegroups.png)

In the subscription hackXXX you will find the following:

![image.png](assets/image.png?t=1697444619538)

Terraform automatically loads the credentials to your local kubectl environment. So this command should work:

```
$ kubectl version                                                                                        ✔  hack8661 ⎈ 
Client Version: v1.28.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.27.3
```

and

```bash
$ kubectl get nodes                                                                                         ✔  hack8661 ⎈ 
NAME                                 STATUS   ROLES   AGE     VERSION
aks-exnodepool-29187889-vmss000000   Ready    agent   2d17h   v1.27.3
```

### Install the Kubernetes part

Go to the Kubernetes directory. We need to define the value for the variable email_adress like so

```bash
echo email_address=<your-email-address> >terraform.auto.tfvars
```

This file is picked automatically and is ignored by git. Run

```shell
terraform init
```

and then

```shell
terraform apply
```

again, confirm with "yes" when asked.

### Verify the result

You should be able to see the following

* ingress-nginx is installed
  * The ingress-nginx has a public IP address
* cert-manager is installed
  * Clusterissuer "letsencrypt-prod" (with your email address)
* kube-prometheus-stack installed
* Namespace "hack"
  * Deployment "api"
    * Reading the secrets for SQL_SERVER_PASSWORD from the KeyVault
    * Horizonal Pod Autoscaler
    * Persitent Volume Claim of type RWX which uses a file share on a storage account
    * Ingress using traefik.me
    * Certificate issued by Let's Encrypt
  * Deployment "web"
    * Horizional Pod Autoscaler
    * Ingress using traefik.me
    * Certificate issued by Let's Encrypt

### Tearing down

Run the command

```shell
terraform destroy
```

first in the Kubernetes, then Azure parts (reverse order)
