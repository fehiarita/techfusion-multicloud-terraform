variable "environment" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "db_name" { type = string }
variable "administrator_login" { type = string }
variable "administrator_password" {
  type      = string
  sensitive = true
}
variable "sku_name" {
  default = "B_Standard_B1ms"
}
variable "storage_mb" {
  default = 32768
}
