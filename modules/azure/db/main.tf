locals {
  name_prefix = lower(replace("tf-${var.environment}-${var.db_name}", "_", "-"))
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "${local.name_prefix}-pg"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "14"
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = { Environment = var.environment }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
