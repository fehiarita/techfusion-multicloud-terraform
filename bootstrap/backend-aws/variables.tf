variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS regions where backend is created"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store Terraform state"
}

variable "lock_table_name" {
  type        = string
  description = "The name of the DynamoDB table to store Terraform state lock"
}