resource "azurerm_network_security_group" "backend" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.appgw.location
  resource_group_name = azurerm_resource_group.appgw.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "211.215.58.26"
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
  security_rule {
    name                       = "https"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "http_8080"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.appgw.id
  network_security_group_id = azurerm_network_security_group.backend.id
}

resource "azurerm_availability_set" "backend" {
  name                         = "${var.prefix}-appgw-avset"
  location                     = azurerm_resource_group.appgw.location
  resource_group_name          = azurerm_resource_group.appgw.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
}

# linux Server 01
resource "azurerm_public_ip" "backend" {
  name                = "${var.prefix}-linux-server-pip"
  resource_group_name = azurerm_resource_group.appgw.name
  location            = azurerm_resource_group.appgw.location
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_network_interface" "backend" {
  name                = "${var.prefix}-linux-server-nic"
  resource_group_name = azurerm_resource_group.appgw.name
  location            = azurerm_resource_group.appgw.location

  ip_configuration {
    name                          = "${var.prefix}-linux-server-ip-config"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.backend.id
  }
}

resource "azurerm_linux_virtual_machine" "linux_server" {
  name                = "${var.prefix}-linux-server"
  resource_group_name = azurerm_resource_group.appgw.name
  location            = azurerm_resource_group.appgw.location
  size                = "Standard_B2s"
  availability_set_id = azurerm_availability_set.backend.id

  network_interface_ids = [
    azurerm_network_interface.backend.id,
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