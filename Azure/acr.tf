// Create azure container registry
resource "azurerm_container_registry" "hack" {
  // TODO Create container registry with SKU Basic in hack resource group. For reference use https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry
}

// Create the container hack/sqlapi:1.0 directly in the ACR
resource "null_resource" "build_api" {
  provisioner "local-exec" {
    command = "echo 'helloworld'"
    // TODO Create image with name hack/sqlapi:1.0 in ACR by using az cli command - Image source can be found in folder ./Resources/api
  }
}

// Create the container hack/web:10 directly in the ACR
// TODO Create a second resource call null_resource.build_web that creates image with name hack/web:1.0 in ACR by using az cli command

resource "time_sleep" "wait_for_images" {
  depends_on      = [null_resource.build_api, null_resource.build_web]
  create_duration = "30s"
}