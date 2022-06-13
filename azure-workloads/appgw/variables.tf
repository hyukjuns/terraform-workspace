# Optional
variable "prefix" {
    description = "prefix"
    default = "tf"
}
variable "suffix" {
    description = "suffix"
    default = "tf-test"
}
variable "location" {
    description = "location"
    default = "koreacentral"
}
variable "admin_username" {
    description = "vm admin username"
    default = "azureuser"
}

# Required
variable "admin_password" {
    description = "vm admin passowrd"
}

variable "agw_host_name" {
  description = " agw listener multisite hostname"
}

variable "agw_backend_hostname" {
  description = "agw_backend_hostname"
}