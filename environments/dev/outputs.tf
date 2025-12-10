output "aws_alb_dns" {
  description = "DNS of the AWS Application Load Balancer"
  value       = module.aws_app.alb_dns_name
}

output "azure_app_hostname" {
  description = "Hostname of the Azure App Service"
  value       = module.azure_app.default_hostname
}

output "aws_cdn_domain" {
  description = "Domain of the AWS CloudFront distribution"
  value       = module.aws_cdn.cloudfront_domain_name
}

output "azure_cdn_endpoint" {
  description = "Endpoint of the Azure Static Website"
  value       = module.azure_cdn.primary_web_endpoint
}
