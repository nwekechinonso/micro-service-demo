# Get the external IP of the front-end service
$ip = kubectl get svc front-end -n sock-shop -o jsonpath="{.status.loadBalancer.ingress[0].ip}"

# Create the certificate YAML with the IP
$certYaml = @"
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
  - $ip
"@

# Apply the certificate YAML to the cluster
$certYaml | kubectl apply -f -
