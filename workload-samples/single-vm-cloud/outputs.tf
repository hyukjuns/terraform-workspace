output "linux_ip" {
    value = azurerm_linux_virtual_machine.linux_server.public_ip_address
}
output "windows_ip" {
    value = azurerm_linux_virtual_machine.linux_server_02.public_ip_address
}