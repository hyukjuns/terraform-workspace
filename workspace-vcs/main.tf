terraform {

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.71.0"
    }
  }
  
  // backend "remote" {
  //   organization = "hyukjun-organization"

  //   workspaces {
  //     name = "workspace-vcs"
  //   }
  // }
}
provider "azurerm" {
    features{}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
}