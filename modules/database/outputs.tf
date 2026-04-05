output "rds_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "RDS connection endpoint"
}

output "rds_port" {
  value = aws_db_instance.main.port
}