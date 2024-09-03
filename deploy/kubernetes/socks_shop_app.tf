# Apply Socks Shop manifests on AKS run command to enable certificate verification
resource "null_resource" "apply_socks_shop_manifests" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name} --admin --overwrite-existing"
    
  }
  provisioner "local-exec" {
    command = "kubectl apply -f complete-demo.yaml"
    
  }
//   provisioner "local-exec" {
//     command = "mkdir C:\\root\\.well-known\\acme-challenge\\"
//   }
// provisioner "local-exec" {
//     command = "echo 'test-content' > C:\\root\\.well-known\\acme-challenge\\testfile"
//   }

  depends_on = [
    azurerm_kubernetes_cluster.main,
  ]
}
#creates name space if they dont exit

// resource "kubernetes_namespace" "monitoring" {
//   metadata {
//     name = "monitoring"
//   }
//   lifecycle {
//     ignore_changes = [metadata]
//   }
//   depends_on = [
//     azurerm_kubernetes_cluster.main,
//   ]
// }