# basic
variable "prefix" {
  default     = "tfcloud"
  description = "naming - prefix"
}
variable "suffix" {
  default     = "dev"
  description = "naming - suffix"
}
variable "location" {
  default     = "koreacentral"
  description = "Primary location"
}

# account
variable "admin_username" {}
variable "admin_password" {}