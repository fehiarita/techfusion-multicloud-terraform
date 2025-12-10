resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  base_name    = lower(replace("tf${var.environment}${var.account_base_name}", "_", ""))
  account_name = substr("${local.base_name}${random_id.suffix.hex}", 0, 24)
}

resource "azurerm_storage_account" "assets" {
  name                     = local.account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  static_website {
    index_document     = var.index_document
    error_404_document = var.error_document
  }
  
  tags = { Environment = var.environment }
}

resource "azurerm_storage_container" "assets" {
  name                  = var.assets_container_name
  storage_account_id    = azurerm_storage_account.assets.id
  container_access_type = "blob"
}
