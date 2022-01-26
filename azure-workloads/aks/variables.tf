variable "prefix" {
  description = "prefix"
  default     = "hj"
}

variable "suffix" {
  description = "suffix"
  default = "nam"
}

variable "resource_group_name" {
  description = "resource group name"
  default = "aks"
}

variable "location" {
  description = "location"
  default = "koreacentral"
}

variable "k8s_version" {
  description = "kubernetes version"
  default = "1.21.7"
}