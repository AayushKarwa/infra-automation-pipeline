# expose module outputs at root
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
    value = module.vpc.nat_gateway_id
  
}

output "alb_dns_name" {
  value       = module.compute.alb_dns_name
  description = "Your app's public URL"
}

output "rds_endpoint" {
  value     = module.database.rds_endpoint
  sensitive = true
}

output "s3_bucket_name" {
  value = module.storage.bucket_name
}