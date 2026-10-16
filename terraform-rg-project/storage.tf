resource "azurerm_storage_account" "storage" {
  name                     = "${var.project_name}storageacct"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  allow_blob_public_access   = false
  min_tls_version            = "TLS1_2"

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}