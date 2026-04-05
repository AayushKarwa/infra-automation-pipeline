variable "project_name"       { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "rds_sg_id"          { type = string }
variable "db_name"            { 
    type = string 
    default = "appdb" 
    }
variable "db_username"        { 
    type = string 
    default = "dbadmin" 
    }
variable "db_password"        { 
    type = string 
    sensitive = true 
    }