# Terraform Cloud for Biz(Ent)
## TF Cloud - Private Module Registry
### module source repo
- Network: https://github.com/hyukjuns/terraform-azurerm-network
- NSG: https://github.com/hyukjuns/terraform-azurerm-nsg
- Public ip: https://github.com/hyukjuns/terraform-azurerm-pip
- Linux: https://github.com/hyukjuns/terraform-azurerm-linux
- Windows: https://github.com/hyukjuns/terraform-azurerm-windows
## TF Cloud - Workspace
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