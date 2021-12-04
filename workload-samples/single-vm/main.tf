terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = " ~> 2.80"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "koreacentral"
  tags = {
    made = "by terraform"
  }
}
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "rdp"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
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
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "subnet" {
  name                 = "default-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}



# linux Server 01
resource "azurerm_public_ip" "linux_server_pip" {
  name                = "${var.prefix}-linux-server-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = "No-Zone"
}

resource "azurerm_network_interface" "linux_server_nic" {
  name                = "${var.prefix}-linux-server-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${var.prefix}-linux-server-nic-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_server_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "linux_server" {
  name                = "${var.prefix}-ubuntu-server"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"

  network_interface_ids = [
    azurerm_network_interface.linux_server_nic.id,
  ]

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

// # window server
// resource "azurerm_public_ip" "windows_server_pip" {
//   name                = "${var.prefix}-windows-server-pip"
//   resource_group_name = azurerm_resource_group.rg.name
//   location            = azurerm_resource_group.rg.location
//   allocation_method   = "Static"
//   sku                 = "Standard"
//   availability_zone = "No-Zone"
// }

// resource "azurerm_network_interface" "windows_server_nic" {
//   name                = "${var.prefix}-windows-server-nic"
//   location            = azurerm_resource_group.rg.location
//   resource_group_name = azurerm_resource_group.rg.name

//   ip_configuration {
//     name                          = "internal"
//     subnet_id                     = azurerm_subnet.subnet.id
//     private_ip_address_allocation = "Dynamic"
//     public_ip_address_id          = azurerm_public_ip.windows_server_pip.id
//   }
// }

// resource "azurerm_windows_virtual_machine" "windows_server" {
//   name                = "${var.prefix}-win-server"
//   resource_group_name = azurerm_resource_group.rg.name
//   location            = azurerm_resource_group.rg.location
//   size                = "Standard_F2"
//   admin_username      = var.admin_username
//   admin_password      = var.admin_password
//   network_interface_ids = [
//     azurerm_network_interface.windows_server_nic.id,
//   ]

//   os_disk {
//     caching              = "ReadWrite"
//     storage_account_type = "Standard_LRS"
//   }

//   source_image_reference {
//     publisher = "MicrosoftWindowsServer"
//     offer     = "WindowsServer"
//     sku       = "2019-Datacenter"
//     version   = "latest"
//   }
// }