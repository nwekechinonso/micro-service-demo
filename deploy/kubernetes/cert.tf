# Install Cert-Manager using Kubernetes manifest
resource "kubernetes_manifest" "cert_manager" {
  for_each = {
    "cert-manager" = "https://github.com/jetstack/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.yaml"
  }
  manifest = yamldecode(file("${each.value}"))
}

# Kubernetes Secret for Azure DNS
resource "kubernetes_secret" "azure_dns_config" {
  metadata {
    name      = "azuredns-config"
    namespace = "cert-manager"
  }
}

# ClusterIssuer YAML Configuration
resource "kubernetes_manifest" "cluster_issuer" {
  manifest = yamldecode(templatefile("cluster-issuer-template.yaml", {
    email_address        = var.email_address,
    client_id            = azuread_service_principal.sp.application_id,
    subscription_id      = var.subscription_id,
    resource_group_name  = var.resource_group_name,
    domain_name          = var.domain_name
  }))
}

# Output the Service Principal credentials
output "sp_credentials" {
  value = {
    app_id     = azuread_service_principal.sp.application_id
    password   = random_password.sp_password.result
  }
  sensitive = true
}

# Create the DNS Zone
resource "azurerm_dns_zone" "main" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.main.name
}

# Define the Kubernetes Service data source to get the ingress controller's external IP
data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [
    null_resource.apply_socks_shop_manifests
  ]
}

# Create a DNS A record pointing to the ingress controller's external IP
resource "azurerm_dns_a_record" "frontend" {
  name                = "sockshop"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300

  records = [
    data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip
  ]

  depends_on = [
    null_resource.apply_socks_shop_manifests
  ]
}

# Output the external IP of the ingress
output "external_ip" {
  value = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip
}
