# aks.tf used to create the AKS cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "socks-shop-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "socks-shop-cluster"
  #number of node to be created(VMSS)
  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }
  # IAM for the cluster
  identity {
    type = "SystemAssigned"
  }
}
#out of the local kube_config that is merged to the azure kube-config
output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_admin_config_raw
  sensitive = true
}
