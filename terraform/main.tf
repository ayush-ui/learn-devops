data "azurerm_resource_group" "existing_rg" {
  name = "myResourceGroup"  # Replace with your actual resource group name
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  dns_prefix          = "myakscluster"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
  }
}
