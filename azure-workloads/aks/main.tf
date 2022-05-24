terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = " ~> 3.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-${var.resource_group_name}"
  location = var.location
}

resource "azurerm_virtual_network" "aks" {
  name                = "${var.prefix}-virtual-network"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "aks" {
  name                 = "azurecni-subnet"
  virtual_network_name = azurerm_virtual_network.aks.name
  resource_group_name  = azurerm_resource_group.aks.name
  address_prefixes     = ["10.240.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks-${var.suffix}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  # k8s version
  kubernetes_version        = var.k8s_version
  automatic_channel_upgrade = "stable"

  # Basic
  dns_prefix = "${var.prefix}aks${var.suffix}"

  default_node_pool {
    name                = "default"
    type                = "VirtualMachineScaleSets"
    zones               = [1, 2, 3]
    node_count          = 3
    vm_size             = "Standard_D2_v2"
    vnet_subnet_id      = azurerm_subnet.aks.id
    enable_auto_scaling = true
    max_count           = 3
    min_count           = 1
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }

  # Network
  network_profile {
    network_plugin     = "azure"
    network_mode       = "transparent"
    network_policy     = "calico"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
    load_balancer_sku  = "standard"
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  # below deprecated
  // role_based_access_control {
  //   enabled = true
  // }

  # Integration
  // addon_profile {
  //   aci_connector_linux {
  //     enabled = false
  //   }
  //   azure_policy {
  //     enabled = false
  //   }
  //   http_application_routing {
  //     enabled = false
  //   }
  //   kube_dashboard {
  //     enabled = false
  //   }
  //   oms_agent {
  //     enabled = true
  //     log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  //   }
  // }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }
  azure_policy_enabled = true
}

# log analytics for container insight
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-la-workspace-01"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
