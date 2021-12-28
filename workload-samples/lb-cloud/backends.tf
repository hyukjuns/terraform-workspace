resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.lb.location
  resource_group_name = azurerm_resource_group.lb.name

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
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_availability_set" "lb" {
  name                         = "${var.prefix}-lb-avset"
  location                     = azurerm_resource_group.lb.location
  resource_group_name          = azurerm_resource_group.lb.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
}

# linux Server 01
resource "azurerm_public_ip" "linux_server_pip" {
  name                = "${var.prefix}-linux-server-pip"
  resource_group_name = azurerm_resource_group.lb.name
  location            = azurerm_resource_group.lb.location
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = "No-Zone"
}

resource "azurerm_network_interface" "linux_server_nic" {
  name                = "${var.prefix}-linux-server-nic"
  resource_group_name = azurerm_resource_group.lb.name
  location            = azurerm_resource_group.lb.location

  ip_configuration {
    name                          = "${var.prefix}-linux-server-nic-ip-config"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_server_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "linux_server" {
  name                = "${var.prefix}-linux-server"
  resource_group_name = azurerm_resource_group.lb.name
  location            = azurerm_resource_group.lb.location
  size                = "Standard_F4s_v2"
  availability_set_id = azurerm_availability_set.lb.id

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

# linux Server 02
resource "azurerm_public_ip" "linux_server_pip_02" {
  name                = "${var.prefix}-linux-server-pip-02"
  resource_group_name = azurerm_resource_group.lb.name
  location            = azurerm_resource_group.lb.location
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = "No-Zone"
}

resource "azurerm_network_interface" "linux_server_nic_02" {
  name                = "${var.prefix}-linux-server-nic-02"
  resource_group_name = azurerm_resource_group.lb.name
  location            = azurerm_resource_group.lb.location

  ip_configuration {
    name                          = "${var.prefix}-linux-server-nic-ip-config-02"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_server_pip_02.id
  }
}

resource "azurerm_linux_virtual_machine" "linux_server_02" {
  name                = "${var.prefix}-linux-server-02"
  resource_group_name = azurerm_resource_group.lb.name
  location            = azurerm_resource_group.lb.location
  size                = "Standard_F4s_v2"
  availability_set_id = azurerm_availability_set.lb.id

  network_interface_ids = [
    azurerm_network_interface.linux_server_nic_02.id,
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