terraform {
  backend "s3" {
    bucket = "infra-automation-terraform-state-file"
    key = "infra-automation/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
    
  }
}