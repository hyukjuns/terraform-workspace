terraform {
  # required_version = "~> 0.14.1"

  # 프로바이더 버전
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.46.0"
    }
  }

  # 원격 백앤드 정보 설정
  #  backend "remote" {
  #    .hol_3_rganization = "hyukjun-test"
  #    workspaces {
  #      name = "hyukjun-test-work2"
  #    }
  #  }
}

# Configure the Azure Provider
provider "azurerm" {
  version = "~> 2.46.0"
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "hol_3_rg" {
  name     = var.resourcegroup
  location = var.location
}

# Create Vnet
resource "azurerm_virtual_network" "vnet_01" {
  name                = "${var.prefix}-vnet-01"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  location            = azurerm_resource_group.hol_3_rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create Subnet00 and Subnet01
resource "azurerm_subnet" "subnet_01" {
  name                 = "${var.prefix}-subnet-01"
  resource_group_name  = azurerm_resource_group.hol_3_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_01.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet_02" {
  name                 = "${var.prefix}-subnet-02"
  resource_group_name  = azurerm_resource_group.hol_3_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_01.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create nsg
resource "azurerm_network_security_group" "nsg_01" {
  name                = "${var.prefix}-nsg_01"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  location            = azurerm_resource_group.hol_3_rg.location
  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = 3389
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = 80
  }
  security_rule {
    name                       = "ICMP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}
resource "azurerm_network_security_group" "nsg_02" {
  name                = "${var.prefix}-nsg-02"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  location            = azurerm_resource_group.hol_3_rg.location
  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = 3389
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = 80
  }
  security_rule {
    name                       = "ICMP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
  security_rule {
    name                       = "SMB"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "445"
  }
}


# Associate nsg to subnet
resource "azurerm_subnet_network_security_group_association" "nsg_associate_01" {
  subnet_id                 = azurerm_subnet.subnet_01.id
  network_security_group_id = azurerm_network_security_group.nsg_01.id
}
resource "azurerm_subnet_network_security_group_association" "nsg_associate_02" {
  subnet_id                 = azurerm_subnet.subnet_02.id
  network_security_group_id = azurerm_network_security_group.nsg_02.id
}

# Create Availability Set
resource "azurerm_availability_set" "avset_01" {
  name                        = "${var.prefix}-avset_01"
  location                    = azurerm_resource_group.hol_3_rg.location
  resource_group_name         = azurerm_resource_group.hol_3_rg.name
  platform_fault_domain_count = 2
}
resource "azurerm_availability_set" "avset_02" {
  name                        = "${var.prefix}-avset-02"
  location                    = azurerm_resource_group.hol_3_rg.location
  resource_group_name         = azurerm_resource_group.hol_3_rg.name
  platform_fault_domain_count = 2
}

# Create NIC
resource "azurerm_network_interface" "nic_01" {
  name                = "${var.prefix}-nic-01"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name

  ip_configuration {
    name                          = "internal-01"
    subnet_id                     = azurerm_subnet.subnet_01.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "nic_02" {
  name                = "${var.prefix}-nic_02"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name

  ip_configuration {
    name                          = "internal-02"
    subnet_id                     = azurerm_subnet.subnet_01.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "nic_03" {
  name                = "${var.prefix}-nic-03"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name

  ip_configuration {
    name                          = "internal-03"
    subnet_id                     = azurerm_subnet.subnet_02.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "nic_04" {
  name                = "${var.prefix}-nic-04"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name

  ip_configuration {
    name                          = "internal-04"
    subnet_id                     = azurerm_subnet.subnet_02.id
    private_ip_address_allocation = "Dynamic"
  }
}


# Create Windows VM
resource "azurerm_windows_virtual_machine" "wvm_01" {
  name                = "${var.prefix}-wvm-01"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  location            = azurerm_resource_group.hol_3_rg.location
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
resource "azurerm_windows_virtual_machine" "wvm_02" {
  name                = "${var.prefix}-wvm-02"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  location            = azurerm_resource_group.hol_3_rg.location
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
resource "azurerm_windows_virtual_machine" "wvm_03" {
  name                = "${var.prefix}-wvm-03"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  location            = azurerm_resource_group.hol_3_rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  availability_set_id = azurerm_availability_set.avset_02.id
  network_interface_ids = [
    azurerm_network_interface.nic_03.id
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
resource "azurerm_windows_virtual_machine" "wvm_04" {
  name                = "${var.prefix}-wvm-04"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  location            = azurerm_resource_group.hol_3_rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  availability_set_id = azurerm_availability_set.avset_02.id
  network_interface_ids = [
    azurerm_network_interface.nic_04.id
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

# Create External LB

# Create Ext lb pip
resource "azurerm_public_ip" "ext_lb_pip" {
  name                = "${var.prefix}-ext-lb-pip"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  allocation_method   = "Static"
}

# Create Ext LB
resource "azurerm_lb" "ext_lb" {
  name                = "${var.prefix}-ext-lb"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-ext-lb-ipconfig"
    public_ip_address_id = azurerm_public_ip.ext_lb_pip.id
  }
}

# Create Ext lb backend pool
resource "azurerm_lb_backend_address_pool" "ext_lb_beppol" {
  name                = "${var.prefix}-ext-lb-bepool"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  loadbalancer_id     = azurerm_lb.ext_lb_pip.id
}

# Associate wvm00 and wvm01 to Backendpool 
resource "azurerm_network_interface_backend_address_pool_association" "ext_lb_bepool_association00" {
  network_interface_id    = azurerm_network_interface.nic_01.id
  ip_configuration_name   = azurerm_network_interface.nic_01.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ext_lb_beppol.id
}
resource "azurerm_network_interface_backend_address_pool_association" "extlb_bepool_association01" {
  network_interface_id    = azurerm_network_interface.nic_02.id
  ip_configuration_name   = azurerm_network_interface.nic_02.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ext_lb_beppol.id
}
resource "azurerm_lb_probe" "ext_lb_hp" {
  name                = "${var.prefix}-ext-lb-hp"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  loadbalancer_id     = azurerm_lb.ext_lb.id
  port                = 80
  protocol            = "http"
  request_path        = "/"
}
resource "azurerm_lb_rule" "extlb_rule" {
  name                           = "extlb-rule"
  resource_group_name            = azurerm_resource_group.hol_3_rg.name
  loadbalancer_id                = azurerm_lb.extlb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.extlb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.extlb_hp.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.extlb_beppol.id
}

# # Create Internal LoadBalancer

resource "azurerm_lb" "intlb" {
  name                = "intlb"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name

  frontend_ip_configuration {
    name                          = "intlb-fip-config"
    subnet_id                     = azurerm_subnet.subnet01.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Int lb backend pool
resource "azurerm_lb_backend_address_pool" "intlb_beppol" {
  name                = "intlb-bepool"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  loadbalancer_id     = azurerm_lb.intlb.id
}

# Associate wvm02 and wvm03 to Backendpool 
resource "azurerm_network_interface_backend_address_pool_association" "intlb_bepool_association00" {
  network_interface_id    = azurerm_network_interface.nic02.id
  ip_configuration_name   = azurerm_network_interface.nic02.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.intlb_beppol.id
}
resource "azurerm_network_interface_backend_address_pool_association" "intlb_bepool_association01" {
  network_interface_id    = azurerm_network_interface.nic03.id
  ip_configuration_name   = azurerm_network_interface.nic03.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.intlb_beppol.id
}
resource "azurerm_lb_probe" "intlb_hp" {
  name                = "intlb-hp"
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  loadbalancer_id     = azurerm_lb.intlb.id
  port                = 80
  protocol            = "http"
  request_path        = "/"
}
resource "azurerm_lb_rule" "intlb_rule" {
  name                           = "intlb-rule"
  resource_group_name            = azurerm_resource_group.hol_3_rg.name
  loadbalancer_id                = azurerm_lb.intlb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.intlb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.intlb_hp.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.intlb_beppol.id
}

# Create Bastion Host
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hol_3_rg.name
  virtual_network_name = azurerm_virtual_network.vnet00.name
  address_prefixes     = ["10.100.0.0/24"]
}
resource "azurerm_public_ip" "bastion_pip" {
  name                = "bastion-pip"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.hol_3_rg]
}

resource "azurerm_bastion_host" "bastion" {
  name                = "AzureBastionHost"
  location            = azurerm_resource_group.hol_3_rg.location
  resource_group_name = azurerm_resource_group.hol_3_rg.name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
# Create FileShare

#Create Storage Account
resource "random_integer" "random" {
  min = 10
  max = 15
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "hjstorageaccount${random_integer.random.result}"
  resource_group_name      = azurerm_resource_group.hol_3_rg.name
  location                 = azurerm_resource_group.hol_3_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "fshare" {
  name                 = "hol_3_rgshare"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 50
}