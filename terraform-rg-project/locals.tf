locals {
  rg_name              = "${var.project_name}-rg"
  aks_name             = "${var.project_name}-aks"
  aks_dns_prefix       = "${var.project_name}aks"
  acr_name             = "${var.project_name}acr"
  kv_name              = "${var.project_name}-kv"
  storage_account_name = "${var.project_name}storageacct"
  storage_container    = "tfstate"
}