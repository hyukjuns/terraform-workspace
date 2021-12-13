output "vm_ip_01" {
    value = azurerm_linux_virtual_machine.linux_server.public_ip_address
}