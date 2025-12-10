# General
variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}



variable "vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "db_password" {
  description = "Password for AWS RDS"
  type        = string
  sensitive   = true
}

# Azure Configuration
variable "azure_location" {
  description = "Azure Region"
  type        = string
  default     = "brazilsouth"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
}

variable "vnet_cidr" {
  description = "CIDR block for Azure VNet"
  type        = string
}

variable "subnet_fe_cidr" {
  description = "CIDR for Azure Frontend Subnet"
  type        = string
}

variable "subnet_be_cidr" {
  description = "CIDR for Azure Backend Subnet"
  type        = string
}

variable "azure_db_password" {
  description = "Password for Azure PostgreSQL"
  type        = string
  sensitive   = true
}
