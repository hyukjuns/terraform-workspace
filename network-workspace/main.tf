terraform {

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.80"
    }
  }
  
  backend "remote" {
    organization = "cloocus-mspdevops"

    workspaces {
      name = "hyukjun-network-workspace"
    }
  }
}
provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}-network-${var.suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "network_dev" {
  name                = "${var.prefix}-vnet-${var.suffix}"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  address_space       = ["10.0.0.0/16"]
  subnet {
    name           = "dev-01"
    address_prefix = "10.0.0.0/24"
  }
}
