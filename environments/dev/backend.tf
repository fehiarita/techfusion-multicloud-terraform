terraform {
  backend "s3" {
    bucket         = "techfusion-hiarita-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "techfusion-hiarita-lock"
    encrypt        = true
  }
}
