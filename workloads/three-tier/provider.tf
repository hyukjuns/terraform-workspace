terraform {
  required_version = "~> 0.14.1"
  
  # 프로바이더 버전
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.46"
    }
  }
  
  # 원격 백앤드 정보 설정
   backend "remote" {
     organization = "hyukjun-demo"
     workspaces {
       name = "dev"
     }
   }
}
# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "web_rg" {
  name     = var.resourcegroup
  location = var.location
}