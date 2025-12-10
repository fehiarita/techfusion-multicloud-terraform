# AWS Network
module "aws_network" {
  source = "../../modules/aws/network"

  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  az1                  = "${var.aws_region}a"
  az2                  = "${var.aws_region}b"
}

# Azure Network
module "azure_network" {
  source = "../../modules/azure/network"

  environment = var.environment
  location    = var.azure_location
  vnet_cidr   = var.vnet_cidr
  subnet_fe   = var.subnet_fe_cidr
  subnet_be   = var.subnet_be_cidr
}

# AWS Application (ECS Fargate)
module "aws_app" {
  source = "../../modules/aws/app"

  health_check_path = "/"
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.aws_network.vpc_id
  public_subnet_ids  = module.aws_network.public_subnet_ids
  private_subnet_ids = module.aws_network.private_subnet_ids

  app_name        = "hiarita-api"
  container_image = "public.ecr.aws/nginx/nginx:latest"
  container_port  = 80
  desired_count   = 2
  cpu             = 512
  memory          = 1024
}

# Azure Application (App Service)
module "azure_app" {
  source = "../../modules/azure/app"

  environment             = var.environment
  location                = module.azure_network.resource_group_location
  resource_group_name     = module.azure_network.resource_group_name
  backend_subnet_id       = module.azure_network.backend_subnet_id
  enable_vnet_integration = true

  app_name            = "techfusion-hiarita-api"
  container_image     = "nginx"
  container_image_tag = "latest"
  sku_name            = "B1"
}

# AWS Database (RDS)
module "aws_db" {
  source = "../../modules/aws/db"

  environment        = var.environment
  vpc_id             = module.aws_network.vpc_id
  private_subnet_ids = module.aws_network.private_subnet_ids
  
  app_name               = "techfusion-api"
  app_security_group_ids = [module.aws_app.app_security_group_id]

  db_name           = "techfusion_hiarita_dev"
  username          = "dbadmin"
  password          = var.db_password
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  multi_az          = true
}

# Azure Database (PostgreSQL Flexible)
module "azure_db" {
  source = "../../modules/azure/db"

  environment         = var.environment
  location            = module.azure_network.resource_group_location
  resource_group_name = module.azure_network.resource_group_name

  db_name                = "techfusion_hiarita_dev"
  administrator_login    = "dbadmin"
  administrator_password = var.azure_db_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
}

# AWS CDN (CloudFront + S3)
module "aws_cdn" {
  source = "../../modules/aws/cdn"

  environment         = var.environment
  bucket_base_name    = "static-assets"
  default_root_object = "index.html"
}

# Azure CDN (Blob + CDN)
module "azure_cdn" {
  source = "../../modules/azure/cdn"

  environment         = var.environment
  location            = module.azure_network.resource_group_location
  resource_group_name = module.azure_network.resource_group_name

  account_base_name     = "assets"
  assets_container_name = "assets"
  enable_static_website = true
  index_document        = "cdn-status.html"
  error_document        = "cdn-status.html"
}
