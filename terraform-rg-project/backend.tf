terraform {
  backend "azurerm" {
    resource_group_name  = "nimbus-rg"
    storage_account_name =   "nimbusstorageacct"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}