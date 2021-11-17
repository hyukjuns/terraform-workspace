output "subnet_dev_01_id" {
  value = azurerm_virtual_network.network_dev.subnet.*.id[0]
}