variable "hack_common_name" {
  description = "The common name for resources generated in the Azure Terraform project (folder). Please define via terraform.tfvars file."
  type        = string
}

variable "mssql_server_administrator_login_password" {
  description = "The password of the mssql server admin account. Please define via terraform.tfvars file."
  type        = string
}