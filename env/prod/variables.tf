variable "aws_region" {
  default = "us-east-1"
}
variable "s3_ckan_storage" {
  default = "storage"
}
variable "s3_cluster_name" {
  default = "ckan-dev"
}

variable "postgres" {
  default = {
    instance_name         = "dx-ckan-db"
    family                = "postgres15"
    instance_class        = "db.m5.large"
    instance_version      = "15.12"
    database_name         = "ckan"
    database_user_name    = "postgres"
    allocated_storage     = "100"
    max_allocated_storage = "150"
    backup_retention      = 7
    maintenance_window    = "Mon:00:00-Mon:03:00"
    backup_window         = "03:00-06:00"
  }

  type = object({
    instance_name         = string
    family                = string
    instance_class        = string
    database_name         = string
    instance_version      = string
    database_user_name    = string
    allocated_storage     = string
    max_allocated_storage = string
    maintenance_window    = string
    backup_window         = string
    backup_retention      = number
  })

}

variable "cluster_issuer" {
  default = {
    #private_key = "key"
    email       = "test@email.com"
  }
}

variable "project_env" {}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "A list of availability zones for subnet placement."
}


variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "A list of CIDR ranges for private subnets."
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  description = "A list of CIDR ranges for public subnets."
}

variable "db_subnet_cidr_blocks" {
  default     = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  description = "A list of CIDR ranges for db subnets."
}

variable "sg_rds_cidr_block" {
  default     = ["10.0.0.0/8"]
  type        = list(string)
  description = "The CIDR range for the RDS security Group"
}

variable "bucket_names" {
  type    = list(string)
  default = ["ckan-dev-storage"]
}

variable "ecr_repositories" {
  type    = list(string)
  default = ["ckan-ecr", "frontend-ecr", "datapusher-ecr"]
}

variable "csi_driver_addon_version" {}