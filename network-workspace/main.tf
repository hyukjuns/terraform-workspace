terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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
  features {}
}

resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}-network-${var.suffix}"
  location = var.location
}

# Network
module "network" {
  source                  = "app.terraform.io/cloocus-mspdevops/network/azurerm"
  version                 = "1.0.0"
  resource_group_name     = azurerm_resource_group.network.name
  location                = azurerm_resource_group.network.location
  vnet_name               = "${var.prefix}-vnet-${var.suffix}"
  address_space           = ["10.0.0.0/16"]
  subnet_name             = "dev-01"
  subnet_address_prefixes = ["10.0.0.0/24"]

  depends_on = [
    azurerm_resource_group.network
  ]
}
# NSG
# Public ip
