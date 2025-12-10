environment = "dev"

# AWS
aws_region           = "us-east-1"
vpc_cidr             = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

# Azure
azure_location = "brazilsouth"
vnet_cidr      = "10.20.0.0/16"
subnet_fe_cidr = "10.20.1.0/24"
subnet_be_cidr = "10.20.2.0/24"

# Secrets (Should be passed via env vars or secret manager in CI/CD)
# db_password       = "..."
# azure_db_password = "..."
