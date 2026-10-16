terraform {
  backend "azurerm" {
    resource_group_name  = "nimbusyan-rg"
    storage_account_name =   "nimbusyanstorageacct"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}