variable "image" {
    description = "ubuntu or centos"
    type = map
    default = {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
}
variable "admin_username" {
    sensitive = true
}
variable "admin_password" {
    sensitive = true
}
variable "prefix" {
    default = "hj"
}