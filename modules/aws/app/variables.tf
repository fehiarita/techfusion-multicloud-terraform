variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "aws_region" { type = string }
variable "app_name" { type = string }
variable "container_image" { type = string }
variable "container_port" {
  type    = number
  default = 80
}
variable "desired_count" {
  type    = number
  default = 2
}
variable "cpu" {
  type    = number
  default = 256
}
variable "memory" {
  type    = number
  default = 512
}
variable "health_check_path" {
  type    = string
  default = "/"
}
