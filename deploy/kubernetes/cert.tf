
resource "null_resource" "apply_cert_manager" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.yaml --validate=false"
  }
}

resource "time_sleep" "wait_for_cert_manager" {
  depends_on      = [null_resource.apply_cert_manager]
  create_duration = "20s"
}


# Kubernetes Secret for Azure DNS
resource "kubernetes_secret" "azure_dns_config" {
  metadata {
    name      = "azuredns-config"
    namespace = "cert-manager"
  }
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
    domain_name         = var.domain_name
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

# Create the DNS Zone
resource "azurerm_dns_zone" "main" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.main.name
}


resource "azurerm_dns_a_record" "frontend_dns" {
  name                = "sockshop"
  zone_name           = "duckdns.org"
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.kubernetes_service.front_end.status[0].load_balancer[0].ingress[0].ip]

  depends_on = [azurerm_kubernetes_cluster.main]
}

# Fetch the external IP of the front-end service
data "kubernetes_service" "front_end" {
  metadata {
    name      = "front-end"
    namespace = "sock-shop"
  }
  depends_on = [null_resource.apply_socks_shop_manifests]
}


resource "null_resource" "wait_for_external_ip" {
  provisioner "local-exec" {
    command = <<EOT
      while ((kubectl get svc front-end -n sock-shop -o jsonpath='{.status.loadBalancer.ingress[0].ip}') -eq "") {
        Write-Host "Waiting for external IP..."
        Start-Sleep -Seconds 10
      }
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [azurerm_kubernetes_cluster.main]
}

resource "null_resource" "apply_certificate" {
  provisioner "local-exec" {
    command = <<EOT
      IP=$(kubectl get svc front-end -n sock-shop -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: sockshop-tls
  namespace: sock-shop
spec:
  secretName: sockshop-tls
  issuerRef:
    name: letsencrypt-azure-dns
    kind: ClusterIssuer
  commonName: sockshop.duckdns.org
  dnsNames:
  - sockshop.duckdns.org
  ipAddresses:
  - $${IP}
EOF
    EOT
  }

  depends_on = [null_resource.wait_for_external_ip]
}