variable "aws_region" {
    description = "AWS region to deploy resources."
    type = string
    default = "ap-south-1"
  
}

variable "project_name" {
    description = "Name or prefix for all the resources."
    type = string
    default = "infra-auto"
  
}

variable "Environment" {
    description = "Deployment environment"
    type = string
    default = "dev"
  
}

variable "vpc_cidr" {
    description = "CIDR block for VPC."
    type = string
    default = "10.0.0.0/16" # 65536 IP's plenty 
  
}

variable "public_subnet_cidr" {
    description = "CIDR blocks for public subnets."
    type = list(string)
    default = [ "10.0.1.0/24","10.0.2.0/24" ]
  
}

variable "availability_zones" {
    description = "AZ's to use."
    type = list(string)
    default = [ "ap-south-1a" ,"ap-south-1b"]
  
}

variable "private_subnet_cidr" {
    description = "CIDR blocks for private subnets."
    type = list(string)
    default = [ "10.0.10.0/24","10.0.11.0/24" ]
  
}

variable "s3-bucket-name" {
    description = "backend s3 bucket name for state file."
    type = string
    default = "infra-automation-terraform-state-file"
}