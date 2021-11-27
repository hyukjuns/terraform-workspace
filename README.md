# Terraform OSS & Cloud for Biz(Ent) & Module
Terraform OSS, Cloud, Module에 관한 개인 저장소 입니다.
[guide](./guide)에 OSS와 Cloud, Module에 관한 내용을 정리하고 있습니다.
## OSS
테라폼을 자유롭게 사용하기 위해 다양한 워크로드를 기록합니다.
### Used Provider
- azurerm
- azuread
- kubernetes
- helm
### Workloads
[Details](./workloads) in Azure and Kubernetes Cluster
## Terraform Cloud for Biz(Ent)
테라폼 클라우드를 다양하게 사용중 입니다.
### Network Workspace
```
- Virtual Network
- Subnet
```
**Remote state**
```
Network Workspace -> Subnet ID-> Compute Workspace
```
### Compute Workspace
```
- VM
   - Linux
   - Windows
- NIC
- Public IP
```
## Module - TF Cloud - Private Module Registry
모듈은 TF Cloud에 Private으로 관리하지만, 모듈 개발은 Github에서 이루어집니다.
### module source repo
- Network: https://github.com/hyukjuns/terraform-azurerm-network
- NSG: https://github.com/hyukjuns/terraform-azurerm-nsg
- Public ip: https://github.com/hyukjuns/terraform-azurerm-pip
- Linux: https://github.com/hyukjuns/terraform-azurerm-linux
- Windows: https://github.com/hyukjuns/terraform-azurerm-windows