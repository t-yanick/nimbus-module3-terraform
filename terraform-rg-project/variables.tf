variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "nimbusyan"
}

variable "location" {
  description = "Azure region to deploy resources (e.g., East US)"
  type        = string
  default     = "South Africa North"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    environment = "Dev"
    owner       = "nimbus"
  }
}

#ACR
variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "nimbusyanacr"
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Basic"
}

#AKS
variable "aks_name" {
  description = "Name of the Azure Kubernetes Service"
  type        = string
  default     = "nimbusyan-aks"
}

variable "aks_node_count" {
  description = "Number of nodes in the Azure Kubernetes Service"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "Size of the virtual machines in the Azure Kubernetes Service"
  type        = string
  default     = "standard_b2s_v2"
}

#Key Vault
variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
  default     = "nimbusyan-kv"
}

variable "key_vault_sku" {
  description = "SKU of the Azure Key Vault"
  type        = string
  default     = "standard"
}

#Storage Account
variable "storage_account_name" {
  description = "Name of the Azure Storage Account"
  type        = string
  default     = "nimbusyanstorageacct"
}

variable "storage_container_name" {
  description = "Name of the storage container"
  type        = string
  default     = "tfstate"
}

#Account replication type for storage account
variable "storage_account_replication_type" {
  description = "Replication type for the Azure Storage Account"
  type        = string
  default     = "LRS"
}