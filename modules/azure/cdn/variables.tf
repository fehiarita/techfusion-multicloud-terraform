variable "environment" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "account_base_name" { type = string }
variable "assets_container_name" { type = string }
variable "enable_static_website" { default = true }
variable "index_document" { default = "index.html" }
variable "error_document" { default = "index.html" }
