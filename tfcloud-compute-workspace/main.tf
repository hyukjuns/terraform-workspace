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
      name = "hyukjun-compute-workspace"
    }
  }
}
provider "azurerm" {
  features {}
}

# network workspace 
data "terraform_remote_state" "network" {
  backend = "remote"
  config = {
    organization = "cloocus-mspdevops"
    workspaces = {
      name = "hyukjun-network-workspace"
    }
  }
}

resource "azurerm_resource_group" "vm" {
  name     = "${var.prefix}-compute-${var.suffix}"
  location = var.location
}

resource "azurerm_network_interface" "linux_01" {
  name                = "${var.prefix}-nic-${var.suffix}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.network.outputs.subnet_dev_01_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.id
  }
}

resource "azurerm_public_ip" "linux_01" {
  name                = "${var.prefix}-pip-${var.suffix}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "linux_01" {
  name                = "${var.prefix}-linux-01-${var.suffix}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location

  # account
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  # nic
  network_interface_ids = [
    azurerm_network_interface.linux_01.id,
  ]

  # spec
  size = "Standard_F2"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}