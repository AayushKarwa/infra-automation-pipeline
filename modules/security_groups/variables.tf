variable "project_name"      { type = string }
variable "vpc_id"            { type = string }
variable "allowed_ssh_cidr"  {
  type        = string
  description = "Your local IP in CIDR format e.g. 203.x.x.x/32"
  default = "223.185.42.150/32"
}