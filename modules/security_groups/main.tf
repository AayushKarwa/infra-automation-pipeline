#------------ALB SECURITY GROUP-------------------
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP/HTTPS from internet"
  vpc_id      = var.vpc_id

   ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg" }
} 
#-------------EC2 SECURITY GROUP------------------
resource "aws_security_group" "ec2" {
  name = "${var.project_name}-ec2-sg"
  description = "Allow traffic only from ALB"
  vpc_id = var.vpc_id
  
  ingress  {
    description = "app port from ALB only"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from your IP"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  
  egress {
    description = "All outbound (package installs, NAT)"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name =  "${var.project_name}-ec2-sg"
  }
}
#-----------------------------RDS SECURITY GROUP----------------------------
resource "aws_security_group" "rds" {
  name = "${var.project_name}-rds-sg"
  description = "Allow postgreSQL only from ec2"
  vpc_id = var.vpc_id

  ingress {
    description = "Requests from ec2 on 5432"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
  
}