terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = " ~> 2.88.1"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cloocus-mspdevops"

    workspaces {
      name = "hyukjnu-module-test-workspace"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "module" {
  name     = "tf-rg"
  location = "koreacentral"
}

# Network
module "network" {
  source                  = "app.terraform.io/cloocus-mspdevops/network/azurerm"
  version                 = "1.0.1"
  vnet_name               = "${var.prefix}-vnet"
  resource_group_name     = azurerm_resource_group.module.name
  location                = azurerm_resource_group.module.location
  address_space           = ["10.0.0.0/16"]
  subnet_name             = "${var.prefix}-subnet"
  subnet_address_prefixes = ["10.0.0.0/24"]
  depends_on = [
    azurerm_resource_group.module
  ]
}

# NSG
module "nsg" {
  source              = "app.terraform.io/cloocus-mspdevops/nsg/azurerm"
  version             = "1.0.1"
  resource_group_name = azurerm_resource_group.module.name
  location            = azurerm_resource_group.module.location
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
    azurerm_resource_group.module
  ]
}
# Public IP
module "public_ip" {
  source              = "app.terraform.io/cloocus-mspdevops/public-ip/azurerm"
  version             = "1.0.1"
  resource_group_name = azurerm_resource_group.module.name
  location            = azurerm_resource_group.module.location
  public_ip_name      = "${var.prefix}-${var.hostname}-pip"
  sku                 = "Standard"
  allocation_method   = "Static"
  availability_zone   = "No-Zone"
  depends_on = [
    azurerm_resource_group.module
  ]
}
# Virtual Machine - Linux
module "linux" {
  source               = "app.terraform.io/cloocus-mspdevops/linux/azurerm"
  version              = "1.0.0"
  resource_group_name  = azurerm_resource_group.module.name
  location             = azurerm_resource_group.module.location
  hostname             = "${var.prefix}-${var.hostname}"
  vm_size              = "Standard_F2"
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  os_disk_sku          = "Standard_LRS"
  publisher            = "Canonical"
  offer                = "UbuntuServer"
  image_sku            = "18.04-LTS"
  os_tag               = "latest"
  subnet_id            = module.network.subnet_id
  nic_name             = "linux-server-nic"
  public_ip_address_id = module.public_ip.public_ip_id
  depends_on = [
    azurerm_resource_group.module
  ]
}