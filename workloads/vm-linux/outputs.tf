output "linux_ip" {
    value = azurerm_linux_virtual_machine.linux_server.public_ip_address
}