# ----------- Resource Group -----------
output "resource_group_name" {
  description = "Name of the deployedresource group"
  value       = azurerm_resource_group.rg.name
}

# ----------- ACR -----------
output "acr_name" {
  description = "Name of the deployed Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Login server URL for 'docker push' — e.g., nimbusyanregistry.azurecr.io"
  value       = azurerm_container_registry.acr.login_server
}

# ----------- AKS -----------
output "aks_name" {
  description = "AKS cluster name — use with: az aks get-credentials --resource-group <rg> --name <this>"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config_raw" {
  description = "Full kubeconfig for the AKS cluster — sensitive, use 'terraform output -raw aks_kube_config_raw'"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

# ----------- Key Vault -----------
output "key_vault_name" {
  description = "Name of the deployed Azure Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "Vault URI — apps use this to read/write secrets"
  value       = azurerm_key_vault.kv.vault_uri
}

# ----------- Storage Account -----------
output "storage_account_name" {
  description = "Name of the deployed Azure Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint URL — e.g., https://nimbusyanstorage.blob.core.windows.net/"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}