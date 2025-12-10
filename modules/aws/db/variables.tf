variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "app_name" { type = string }
variable "app_security_group_ids" { type = list(string) }
variable "db_name" { type = string }
variable "username" { type = string }
variable "password" {
  type      = string
  sensitive = true
}
variable "engine" {
  default = "postgres"
}
variable "instance_class" {
  default = "db.t3.micro"
}
variable "allocated_storage" {
  default = 20
}
variable "db_port" {
  default = 5432
}
variable "multi_az" {
  default = false
}
