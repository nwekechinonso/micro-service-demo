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

# Service Principal associated with the Azure AD Application
resource "azuread_service_principal" "sp" {
  application_id = azuread_application.sp.application_id
}

# Create Azure AD Application
resource "azuread_application" "sp" {
  display_name = var.sp_name
}
# Generate a random password for the service principal
resource "random_password" "sp_password" {
  length  = 32
  special = true
}

# Role assignment for DNS Zone Contributor role
resource "azurerm_role_assignment" "dns_zone_contributor" {
  principal_id         = azuread_service_principal.sp.object_id
  role_definition_name = "DNS Zone Contributor"
  scope                = azurerm_resource_group.main.id
}