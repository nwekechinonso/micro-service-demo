# role_assignments for the cluster
resource "azurerm_role_assignment" "aks_contributor" {
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}
#create the role access for the cluters
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_subnet.subnet_a.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

# Service Principal

resource "azurerm_service_principal" "sp" {
  application_id = azurerm_ad_application.sp.application_id
}

resource "azurerm_ad_application" "sp" {
  display_name = var.sp_name
}

resource "random_password" "sp_password" {
  length  = 32
  special = true
}

resource "azurerm_service_principal_password" "sp_password" {
  service_principal_id = azurerm_service_principal.sp.id
  value                = random_password.sp_password.result
  end_date             = "2099-12-31T23:59:59Z"
}

resource "azurerm_role_assignment" "dns_zone_contributor" {
  principal_id   = azurerm_service_principal.sp.application_id
  role_definition_name = "DNS Zone Contributor"
  scope          = azurerm_resource_group.main.id
}