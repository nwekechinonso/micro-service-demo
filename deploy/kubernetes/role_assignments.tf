# role_assignments.tf
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
