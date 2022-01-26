# tfvars에도 값이 없으면 prompt창에 입력해야함
variable "location" {
  default = "koreacentral"
}
variable "admin_username" {}
variable "admin_password" {}

# tfvars에 값이 있으면 tfvars가 우선순위임
variable "prefix" {
  type    = string
  default = "my"
}

variable "tags" {
  type = map(any)

  default = {
    Environment = "Terraform GS"
    Dept        = "Engineering"
  }
}

variable "sku" {
  default = {
    westus2      = "16.04-LTS"
    eastus       = "18.04-LTS"
    koreacentral = "18.04-LTS"
  }
}
