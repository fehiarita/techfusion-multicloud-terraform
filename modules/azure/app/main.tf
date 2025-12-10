locals {
  name_prefix = "tf-${var.environment}-${var.app_name}"
}

resource "azurerm_service_plan" "this" {
  name                = "${local.name_prefix}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = { Environment = var.environment }
}

resource "azurerm_linux_web_app" "this" {
  name                = "${local.name_prefix}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true

  site_config {
    always_on = true
    application_stack {
      docker_image_name   = "${var.container_image}:${var.container_image_tag}"
    }
  }

  app_settings = {
    WEBSITES_PORT = "80"
  }

  tags = { Environment = var.environment }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet" {
  count          = var.enable_vnet_integration ? 1 : 0
  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.backend_subnet_id
}
