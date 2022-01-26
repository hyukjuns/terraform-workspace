### Ref
- AKS Hashicorp Docs
    - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#attributes-reference
- AKS Examples in hashicorp
    - https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/kubernetes

### Mark kubeconfig as Sensitive Variable
```
export TF_ARM_AKS_KUBE_CONFIGS_SENSITIVE=true
```
