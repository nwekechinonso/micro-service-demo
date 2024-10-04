
resource "null_resource" "apply_cert_manager" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.yaml --validate=false"
  }
  # Add a condition to skip this step if cert-manager is already installed
  depends_on = [azurerm_kubernetes_cluster.main]
}


resource "time_sleep" "wait_for_cert_manager" {
  depends_on      = [null_resource.apply_cert_manager]
  create_duration = "20s"
}


# ClusterIssuer YAML Configuration
locals {
  aks_cluster_available = false
}
resource "kubernetes_manifest" "cluster_issuer" {
  count = local.aks_cluster_available ? 1 : 0
  manifest = yamldecode(templatefile("cluster-issuer-template.yaml", {
    email_address       = var.email_address,
    client_id           = azuread_service_principal.sp.application_id,
    subscription_id     = var.subscription_id,
    resource_group_name = var.resource_group_name,
    domain_name         = var.domain_name,
    tenant_id           = var.tenant_id
  }))
  depends_on = [null_resource.apply_cert_manager]
}

# Output the Service Principal credentials
output "sp_credentials" {
  value = {
    app_id   = azuread_service_principal.sp.application_id
    password = random_password.sp_password.result
  }
  sensitive = true
}

resource "null_resource" "apply_certificate" {
  provisioner "local-exec" {
    command = "powershell.exe -ExecutionPolicy Bypass -File ./create-cert.ps1"
  }
  depends_on = [null_resource.apply_cert_manager]
}