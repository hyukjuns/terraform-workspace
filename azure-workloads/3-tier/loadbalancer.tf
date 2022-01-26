resource "azurerm_lb" "dev_business_lb" {
  name                = "${var.prefix}-business-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.web_rg.name
  sku                 = "Basic"
  frontend_ip_configuration {
    name                          = "business-lb-private-ip"
    subnet_id                     = azurerm_subnet.dev_business_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "dev_business_lb_bepool" {
  loadbalancer_id = azurerm_lb.dev_business_lb.id
  name            = "BackEndAddressPool"
}

# ip_configuration_name: nic config name
resource "azurerm_network_interface_backend_address_pool_association" "dev_business_lb_association_00" {
  network_interface_id    = azurerm_network_interface.dev_business_nic_00.id
  ip_configuration_name   = azurerm_network_interface.dev_business_nic_00.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.dev_business_lb_bepool.id
}
resource "azurerm_network_interface_backend_address_pool_association" "dev_business_lb_association_01" {
  network_interface_id    = azurerm_network_interface.dev_business_nic_01.id
  ip_configuration_name   = azurerm_network_interface.dev_business_nic_01.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.dev_business_lb_bepool.id
}

resource "azurerm_lb_probe" "dev_business_lb_probe" {
  resource_group_name = azurerm_resource_group.web_rg.name
  loadbalancer_id     = azurerm_lb.dev_business_lb.id
  name                = "tomcat-running-probe"
  port                = 8009
}

resource "azurerm_lb_rule" "dev_business_lb_rule" {
  resource_group_name            = azurerm_resource_group.web_rg.name
  loadbalancer_id                = azurerm_lb.dev_business_lb.id
  name                           = "LBRule-01"
  protocol                       = "Tcp"
  frontend_port                  = 8009
  backend_port                   = 8009
  frontend_ip_configuration_name = azurerm_lb.dev_business_lb.frontend_ip_configuration[0].name
}
