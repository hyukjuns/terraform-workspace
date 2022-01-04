# Terraform Workloads
Terraform OSS, Cloud, Module에 관한 개인 저장소 입니다.

### Terraform Version
- ~> 1.1.x
- Version Control Tool
   - tfenv (2.0.0-37-g0494129)
- Key Changelog
   - 0.x.x ~ 1.0.x -> 1.1.x
      - terraform cloud remote backend 선언 방법 변경
         ```
         0.1x.x ~ 1.0.x
         terraform {
            backend "remote" {
               hostname     = "app.terraform.io"
               organization = "ORGNAME"

               workspaces {
                  name = "WORKSPACENAME"
               }
            }
         }

         >= 1.1.0
         terraform {
            cloud {
               organization = "ORGNAME"

               workspaces {
                  name = "WORKSPACENAME"
               }
            }
         }
         ```
### Environments
- Azure
- Kubernetes

### Used Provider
- azurerm
- azuread
- kubernetes
- helm

### Remote Backends
- Terraform Cloud
- Azure Blob
- Local
### Terraform with CI/CD
- Azure DevOps
### Module
- Private Registry
   - Terraform Cloud
- Module Repositroies
   - Network: https://github.com/hyukjuns/terraform-azurerm-network
   - NSG: https://github.com/hyukjuns/terraform-azurerm-nsg
   - Public ip: https://github.com/hyukjuns/terraform-azurerm-pip
   - Linux: https://github.com/hyukjuns/terraform-azurerm-linux
   - Windows: https://github.com/hyukjuns/terraform-azurerm-windows