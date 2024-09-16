resource "null_resource" "apply_socks_shop_manifests" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name} --admin --overwrite-existing"

  }
  provisioner "local-exec" {
    command = "kubectl apply -f complete-demo.yaml"

  }

  depends_on = [
    azurerm_kubernetes_cluster.main,
  ]
}

resource "time_sleep" "wait_for_socks_shop_manifests" {
  depends_on      = [null_resource.apply_socks_shop_manifests]
  create_duration = "20s"
}