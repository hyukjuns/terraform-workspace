variable "resourcegroup" {
    type = string
    default = "TF-rg"
}
variable "location" {
    type = string
    default = "koreacentral"
}
variable "prefix"{
    default = "hol-2"
}
variable "admin_username" {
    description = "vm admin username"
}
variable "admin_password" {
    description = "vm admin password"
}