variable "project_name"       { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }
variable "ec2_sg_id"          { type = string }
variable "alb_sg_id"          { type = string }
variable "instance_type"      { 
     type = string
     default = "t3.micro"
      }
variable "instance_count"   { 
type = number
   default = 2 
   }
variable "public_key_path"    { type = string }