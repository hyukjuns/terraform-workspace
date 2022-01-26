output "windows_ip" {
    value = azurerm_windows_virtual_machine.windows_server.public_ip_address
}