# upload the .crt and .key file to your clusters(files are created by certbot)

resource "kubernetes_secret" "tls_cert" {
  metadata {
    name      = "tls-cert"
    namespace = "default"
  }

  data = {
    tls.crt = filebase64("${path.module}/path/to/your/cert.crt")
    tls.key = filebase64("${path.module}/path/to/your/cert.key")
  }

  type = "kubernetes.io/tls"
}
# you can comment this out because i have already added it to the complete-demo.yaml file

resource "kubernetes_ingress" "sockshop_ingress" {
  metadata {
    name      = "sockshop-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    tls {
      secret_name = kubernetes_secret.tls_cert.metadata[0].name
      hosts       = ["sockshop.duckdns.org"]
    }

    rule {
      host = "sockshop.duckdns.org"

      http {
        path {
          path = "/"
          backend {
            service_name = "sockshop-service"
            service_port = 80
          }
        }
      }
    }
  }
}
