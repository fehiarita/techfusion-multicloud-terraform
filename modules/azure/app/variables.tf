variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "app_name" { type = string }
variable "container_image" { type = string }
variable "container_image_tag" {
  default = "latest"
}
variable "sku_name" {
  default = "B1"
}
variable "backend_subnet_id" {
  default = null
}
variable "enable_vnet_integration" {
  default = false
}
