terraform {
  # required_version = "~> 0.14.1"

  # 프로바이더 버전
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.46"
    }
  }

  # 원격 백앤드 정보 설정
  #  backend "remote" {
  #    organization = "hyukjun-test"
  #    workspaces {
  #      name = "hyukjun-test-work2"
  #    }
  #  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "hol_2_rg" {
  name     = var.resourcegroup
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet_01" {
  name                = "${var.prefix}-vnet-01"
  resource_group_name = azurerm_resource_group.hol_2_rg.name
  location            = azurerm_resource_group.hol_2_rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create Subnet
resource "azurerm_subnet" "subnet_01" {
  name                 = "${var.prefix}-subnet_01"
  resource_group_name  = azurerm_resource_group.hol_2_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_01.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create NSG
resource "azurerm_network_security_group" "nsg_01" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.hol_2_rg.location
  resource_group_name = azurerm_resource_group.hol_2_rg.name
  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "icmp"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "nsg_subnet_association_01" {
  subnet_id                 = azurerm_subnet.subnet_01.id
  network_security_group_id = azurerm_network_security_group.nsg_01.id
}

# Create lb
resource "azurerm_public_ip" "ext_lb_pip" {
  name                = "${var.prefix}-PublicIPForExtLB"
  location            = var.location
  resource_group_name = var.resourcegroup
  allocation_method   = "Static"
}

resource "azurerm_lb" "ext_lb" {
  name                = "${var.prefix}-ext-lb"
  location            = var.location
  resource_group_name = var.resourcegroup

  frontend_ip_configuration {
    name                 = "${var.prefix}-ext-lb-ipconfig"
    public_ip_address_id = azurerm_public_ip.ext_lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "ext_lb_bepool" {
  name                = "${var.prefix}-ext-lb-bepool"
  resource_group_name = var.resourcegroup
  loadbalancer_id     = azurerm_lb.ext_lb.id
}

resource "azurerm_lb_probe" "ext_lb_hp" {
  name                = "${var.prefix}-ext-lb-probe"
  resource_group_name = var.resourcegroup
  loadbalancer_id     = azurerm_lb.ext_lb.id
  port                = 80
  protocol            = "http"
  request_path        = "/"
}

resource "azurerm_lb_rule" "ext_lb_rule" {
  name                           = "${var.prefix}-ext_lb-rule"
  resource_group_name            = var.resourcegroup
  loadbalancer_id                = azurerm_lb.ext_lb.id
  frontend_port                  = 80
  backend_port                   = 80
  protocol                       = "Tcp"
  probe_id                       = azurerm_lb_probe.ext_lb_hp.id
  frontend_ip_configuration_name = azurerm_lb.ext_lb.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ext_lb_bepool.id
}
resource "azurerm_lb_nat_pool" "ext_lb_natpool" {
  name                           = "${var.prefix}-ext-lb-natpool"
  resource_group_name            = var.resourcegroup
  loadbalancer_id                = azurerm_lb.ext_lb.id
  protocol                       = "Tcp"
  frontend_port_start            = "5000"
  frontend_port_end              = "5010"
  backend_port                   = 3389
  frontend_ip_configuration_name = azurerm_lb.ext_lb.frontend_ip_configuration[0].name
}

# Create Windows vmss
resource "azurerm_windows_virtual_machine_scale_set" "win_vmss" {
  name                 = "windows-vmss"
  computer_name_prefix = var.prefix
  location             = var.location
  resource_group_name  = var.resourcegroup
  sku                  = "Standard_DS1_v2"
  instances            = 2
  admin_username       = var.admin_username
  admin_password       = var.admin_password

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.prefix}-vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet_01.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.ext_lb_bepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.ext_lb_natpool.id]
    }
  }
}
