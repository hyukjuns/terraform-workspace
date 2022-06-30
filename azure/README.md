## Terraform Provider & Remote backend
- Terraform Cloud
    ```
    terraform {
        required_providers {
                azurerm = {
                source  = "hashicorp/azurerm"
                version = "~> 2.89.0"
            }
        }
        cloud {
            organization = "ORGNAME"

            workspaces {
                name = "WORKSPACENAME"
            }
        }
    }
    ```
- AzureRM
    ```
    terraform {
        required_providers {
            azurerm = {
                source  = "hashicorp/azurerm"
                version = "~> 2.89.0"
            }
        }
        backend "azurerm" {
            resource_group_name  = "RESOURCEGROUP"
            storage_account_name = "STORAGEACCOUNT"
            container_name       = "CONTAINER"
            key                  = "FILENAME"
        }
    }
    ```
## Terraform Cloud tfvars
Excution Mode
- Remote
    - *.auto.tfvars
- Local
    - terraform.tfvars
## Terraform Environment Variables
- https://www.terraform.io/cli/config/environment-variables

## azcli
### vm image list
- Publisher: The organization that created the image. Examples: Canonical, RedHat, OpenLogic
- Offer: The name of a group of related images created by a publisher. Examples: UbuntuServer, RHEL, CentOS
- SKU: An instance of an offer, such as a major release of a distribution. Examples: 16.04-LTS, 7-RAW, 7.5
- Version: The version number of an image SKU.
```
az vm image list -f CentOS -p OpenLogic -s 7 -l koreacentral --all
```