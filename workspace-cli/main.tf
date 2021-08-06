terraform {

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.71.0"
    }
  }
  
  backend "remote" {
    organization = "hyukjun-organization"

    workspaces {
      name = "workspace-cli"
    }
  }
}
provider "azurerm" {
    features{}
}

data "terraform_remote_state" "vnet" {
  backend = "remote"

  config = {
    organization = "hyukjun-organization"
    workspaces = {
      name = "workspace-vcs"
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = data.terraform_remote_state.vnet.output.location
  resource_group_name = data.terraform_remote_state.vnet.output.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.vnet.output.subnet_info.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "${var.prefix}-linux-machine"
  resource_group_name = data.terraform_remote_state.vnet.output.rg
  location            = data.terraform_remote_state.vnet.output.location
  size                = "Standard_F2"
  admin_username      = var.username
  admin_password = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

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