terraform {
  required_version = "~> 0.14.1"

  # 프로바이더 버전
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.46"
    }
  }

  # 원격 백앤드 정보 설정
  backend "remote" {
    organization = "hyukjun-demo"
    workspaces {
      name = "azure-infra-01"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "hol_1_rg" {
  name     = var.resourcegroup
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  location            = azurerm_resource_group.hol_1_rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create Subnet
resource "azurerm_subnet" "subnet_01" {
  name                 = "${var.prefix}-subnet-01"
  resource_group_name  = azurerm_resource_group.hol_1_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.hol_1_rg.location
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 110
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
    priority                   = 120
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
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "nsg_subnet_01" {
  subnet_id                 = azurerm_subnet.subnet_01.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create Availability Set
resource "azurerm_availability_set" "avset_01" {
  name                        = "${var.prefix}-avset-01"
  location                    = azurerm_resource_group.hol_1_rg.location
  resource_group_name         = azurerm_resource_group.hol_1_rg.name
  platform_fault_domain_count = 2
}
# Create NIC
resource "azurerm_network_interface" "nic_01" {
  name                = "${var.prefix}-nic-01"
  location            = azurerm_resource_group.hol_1_rg.location
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_01.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create Winow Virtual Machines
resource "azurerm_windows_virtual_machine" "wvm_01" {
  name                = "${var.prefix}-wvm01"
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  location            = azurerm_resource_group.hol_1_rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  availability_set_id = azurerm_availability_set.avset_01.id
  network_interface_ids = [
    azurerm_network_interface.nic_01.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_network_interface" "nic_02" {
  name                = "${var.prefix}-nic-02"
  location            = azurerm_resource_group.hol_1_rg.location
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  ip_configuration {
    name                          = "internal-02"
    subnet_id                     = azurerm_subnet.subnet_01.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_windows_virtual_machine" "wvm_02" {
  name                = "${var.prefix}-wvm-02"
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  location            = azurerm_resource_group.hol_1_rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  availability_set_id = azurerm_availability_set.avset_01.id
  network_interface_ids = [
    azurerm_network_interface.nic_02.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# Create LB
resource "azurerm_public_ip" "extlb_pip" {
  name                = "PublicIPForLB"
  location            = var.location
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  allocation_method   = "Static"
}
resource "azurerm_lb" "extlb" {
  name                = "TestLoadBalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  frontend_ip_configuration {
    name                 = "${var.prefix}-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.extlb_pip.id
  }
}
resource "azurerm_lb_backend_address_pool" "extlb_bepool" {
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  loadbalancer_id     = azurerm_lb.extlb.id
  name                = "BackEndAddressPool"
}
resource "azurerm_lb_probe" "extlb_hp" {
  resource_group_name = azurerm_resource_group.hol_1_rg.name
  loadbalancer_id     = azurerm_lb.extlb.id
  name                = "${var.prefix}-probe"
  port                = 80
  protocol            = "http"
  request_path        = "/"
}
resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = azurerm_resource_group.hol_1_rg.name
  loadbalancer_id                = azurerm_lb.extlb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.prefix}-PublicIPAddress"
  probe_id                       = azurerm_lb_probe.extlb_hp.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.extlb_bepool.id
}
# Inbound NAT Rule
resource "azurerm_network_interface_backend_address_pool_association" "be_associate_01" {
  network_interface_id    = azurerm_network_interface.nic_01.id
  ip_configuration_name   = azurerm_network_interface.nic_01.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.extlb_bepool.id

}
resource "azurerm_network_interface_backend_address_pool_association" "be_associate_02" {
  network_interface_id    = azurerm_network_interface.nic_02.id
  ip_configuration_name   = azurerm_network_interface.nic_02.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.extlb_bepool.id
}
resource "azurerm_lb_nat_rule" "extlb_natrule_01" {
  resource_group_name            = azurerm_resource_group.hol_1_rg.name
  loadbalancer_id                = azurerm_lb.extlb.id
  name                           = "RDPAccess-00"
  protocol                       = "Tcp"
  frontend_port                  = 5000
  backend_port                   = 3389
  frontend_ip_configuration_name = "${var.prefix}-PublicIPAddress"
}
resource "azurerm_lb_nat_rule" "extlb_natrule_02" {
  resource_group_name            = azurerm_resource_group.hol_1_rg.name
  loadbalancer_id                = azurerm_lb.extlb.id
  name                           = "RDPAccess-01"
  protocol                       = "Tcp"
  frontend_port                  = 5001
  backend_port                   = 3389
  frontend_ip_configuration_name = "${var.prefix}-PublicIPAddress"
}
resource "azurerm_network_interface_nat_rule_association" "nic_natrule_01" {
  network_interface_id  = azurerm_network_interface.nic_01.id
  ip_configuration_name = azurerm_network_interface.nic_01.ip_configuration[0].name
  nat_rule_id           = azurerm_lb_nat_rule.extlb_natrule_01.id
}
resource "azurerm_network_interface_nat_rule_association" "nic_natrule_02" {
  network_interface_id  = azurerm_network_interface.nic_02.id
  ip_configuration_name = azurerm_network_interface.nic_02.ip_configuration[0].name
  nat_rule_id           = azurerm_lb_nat_rule.extlb_natrule_02.id
}