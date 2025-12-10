output "resource_group_name" { value = azurerm_resource_group.this.name }
output "resource_group_location" { value = azurerm_resource_group.this.location }
output "vnet_id" { value = azurerm_virtual_network.this.id }
output "backend_subnet_id" { value = azurerm_subnet.backend.id }
