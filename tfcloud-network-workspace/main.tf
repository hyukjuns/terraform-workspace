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
  version                 = "1.0.1"
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
module "nsg" {
  source              = "app.terraform.io/cloocus-mspdevops/nsg/azurerm"
  version             = "1.0.1"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  nsg_name            = "${var.prefix}-nsg"

  rules = [
    {
      name                       = "ssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
    },
    {
      name                       = "http"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "80,8080"
    }
  ]

  attach_to_subnet = [module.network.subnet_id]
  depends_on = [
    azurerm_resource_group.network
  ]
}