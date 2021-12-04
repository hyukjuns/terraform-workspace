# main, network variables
variable "location" {
  description = "region info"
  default     = "koreacentral"
}
variable "resourcegroup" {
  description = "resource group name"
  default     = "TF-dev"
}
variable "prefix" {
  description = "environment name"
  default     = "dev"
}
variable "src_ip" {
  description = "company public ip"
}
#Compute
variable "admin_username" {
  description = "vm host name"
}
variable "admin_password" {
  description = "vm host password"
}