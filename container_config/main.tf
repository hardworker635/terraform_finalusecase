terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0.0"
      
    }
  }
} 

provider "azurerm" {
  features {

  }
  subscription_id = "75449c00-4ce4-4f05-9b99-eed70a7a19ff"
  tenant_id = "4cf43e32-b5ce-4265-b26d-5dae5449c222"
}

# creation of a resource group
resource "azurerm_resource_group" "dev_rg" {

    name = "DevEnvironment-RG"
    location = "East US"

}
resource "azurerm_container_registry" "dev_acr" {
  name                = "devenvfinalusecaseapp"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = "East US"
  sku                 = "Basic"
  

  }

resource "azurerm_kubernetes_cluster" "dev_aks" {
  name                = "dev_AKS"
  location            = "East US"
  resource_group_name = azurerm_resource_group.dev_rg.name
  dns_prefix          = "devaks"
  sku_tier = "Free"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }
  identity {
    type = "SystemAssigned"
  }


}
resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.dev_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.dev_acr.id
  skip_service_principal_aad_check = true
}
