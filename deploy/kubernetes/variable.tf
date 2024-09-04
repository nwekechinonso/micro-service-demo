
# Variables
variable "subscription_id" {
  description = "Azure Subscription ID."
  default     = "1f0ec4ef-e180-4466-9c30-2e149184e9ab"
}

variable "resource_group_name" {
  description = "Resource Group name where resources will be created."
  default     = "socks-shop-resources"
}

variable "email_address" {
  description = "Email address to use with Let's Encrypt."
  type        = string
}

variable "domain_name" {
  description = "The domain name for which the certificates will be issued."
  default     = "sockshop.duckdns.org"
}

variable "sp_name" {
  description = "Service Principal name for DNS zone management."
  default     = "cert-manager-dnssp"
}

variable "aks_cluster_name" {
  description = "AKS Cluster name."
  default     = "main"
}

variable "cert_manager_version" {
  description = "Version of Cert-Manager to install."
  default     = "v1.14.5"
}