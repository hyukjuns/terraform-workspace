output "linux_ip_0" {
    value = azurerm_linux_virtual_machine.linux_server[0].public_ip_address
}
output "linux_ip_1" {
    value = azurerm_linux_virtual_machine.linux_server[1].public_ip_address
}