output "rg" {
    value = azurerm_resource_group.rg.name
}
output "location" {
    value = azurerm_resource_group.rg.location
}
output "subnet_info" {
    value = tolist(azurerm_virtual_network.vnet.subnet)[0]
}