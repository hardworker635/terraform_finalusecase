terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.0.0"
      
    }
  }
} 

provider "azurerm" {
  features {

  }
  subscription_id = "75449c00-4ce4-4f05-9b99-eed70a7a19ff"
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

resource "azurerm_container_registry_scope_map" "dev_acr_map" {
    name = "devacrscopemap"
    container_registry_name = azurerm_container_registry.dev_acr.name
    resource_group_name = azurerm_resource_group.dev_rg.name
    actions = [
    "repositories/*/content/read",
    "repositories/*/content/write"
  ] # This gives the token permission to pull/push to all repositories. You can customize this per repo if needed.
}

resource "azurerm_container_registry_token" "dev_acr_token" {
  name                    = "devacrtoken"
  container_registry_name = azurerm_container_registry.dev_acr.name
  resource_group_name     = azurerm_resource_group.dev_rg.name
  scope_map_id            = azurerm_container_registry_scope_map.dev_acr_map.id

}

resource "azurerm_container_registry_token_password" "dev_acr_token_pswd" {
  container_registry_token_id = azurerm_container_registry_token.dev_acr_token.id

  password1 {
   
  } 

}

#output "acr_token_username" {
 # value = azurerm_container_registry_token.dev_acr_token.name
#}

output "acr_token_password" {
  value     = azurerm_container_registry_token_password.dev_acr_token_pswd.password1[0]
  sensitive = true
}