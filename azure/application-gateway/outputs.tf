output "linux_pip" {
  value = azurerm_linux_virtual_machine.linux_server.public_ip_address
}
output "application_gateway_pip" {
  value = azurerm_public_ip.appgw.ip_address
}