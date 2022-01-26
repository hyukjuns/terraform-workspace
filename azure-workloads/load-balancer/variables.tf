# Optional
variable "prefix" {
  description = "prefix"
  default     = "hj"
}
variable "suffix" {
  description = "suffix"
  default     = "nam"
}
variable "location" {
  description = "location"
  default     = "koreacentral"
}
variable "admin_username" {
  description = "vm admin username"
  default     = "az"
}

# Required
variable "admin_password" {
  description = "vm admin username"
}