# Install Cert-Manager
resource "kubernetes_manifest" "cert_manager" {
  for_each = {
    "cert-manager"     = "https://github.com/jetstack/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.yaml"
  }
  manifest = yamldecode(file("${each.value}"))
}

# Kubernetes Secret for Azure DNS
resource "kubernetes_secret" "azure_dns_config" {
  metadata {
    name      = "azuredns-config"
    namespace = "cert-manager"
  }

  data = {
    client-secret = base64encode(azurerm_service_principal_password.sp_password.value)
  }
}

# ClusterIssuer YAML Configuration
resource "kubernetes_manifest" "cluster_issuer" {
  manifest = yamldecode(templatefile("templates/cluster-issuer-template.yaml", {
    email_address        = var.email_address,
    client_id            = azurerm_service_principal.sp.application_id,
    subscription_id      = var.subscription_id,
    tenant_id            = azurerm_service_principal.sp.tenant_id,
    resource_group_name  = var.resource_group_name,
    domain_name          = var.domain_name
  }))
}

output "sp_credentials" {
  value = {
    app_id     = azurerm_service_principal.sp.application_id
    tenant     = azurerm_service_principal.sp.tenant_id
    password   = azurerm_service_principal_password.sp_password.result
  }
  sensitive = false
}

# Create the DNS Zone
resource "azurerm_dns_zone" "main" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.main.name
}