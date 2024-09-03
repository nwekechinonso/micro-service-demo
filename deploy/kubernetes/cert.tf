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

