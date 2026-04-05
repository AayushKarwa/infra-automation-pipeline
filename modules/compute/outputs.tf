output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "Hit this URL to reach your app"
}

output "ec2_instance_ids" {
  value = aws_instance.app[*].id
}

output "ec2_private_ips" {
  value = aws_instance.app[*].private_ip
}