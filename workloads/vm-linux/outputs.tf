output "linux_ip_0" {
    value = azurerm_linux_virtual_machine.linux_server[0].public_ip_address
}