# basic
variable "prefix" {
    default = "tfcloud"
    description = "naming - prefix"
}
variable "suffix" {
    default = "dev"
    description = "naming - suffix"
}
variable "location" {
    default = "koreacentral"
    description = "Primary location"
}

# account
variable "admin_username" {
  default = "azureuser"
}
variable "admin_password" {
  default = "dkagh1.dakgh1."
}