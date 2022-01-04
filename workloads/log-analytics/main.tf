terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = " ~> 2.88.1"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "la" {
  name = "test"
}

resource "azurerm_log_analytics_workspace" "la" {
  name                = "test-la-01"
  resource_group_name = data.azurerm_resource_group.la.name
  location            = data.azurerm_resource_group.la.location
  sku                 = "PerGB2018"
}

output "la_name" {
    value = azurerm_log_analytics_workspace.la.name
}