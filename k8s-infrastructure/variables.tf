variable "project_env" {
  type        = string
  description = "A project namespace for the infrastructure."
  default     = "dev"
}

variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "A valid AWS region to configure the underlying AWS SDK."
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "A list of availability zones for subnet placement."
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.2.0/24","10.0.3.0/24"]
  description = "A list of CIDR ranges for private subnets."
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.4.0/24", "10.0.5.0/24","10.0.6.0/24"]
  description = "A list of CIDR ranges for public subnets."
}

variable "db_subnet_cidr_blocks" {
  default     = ["10.0.7.0/24", "10.0.8.0/24","10.0.9.0/24"]
  description = "A list of CIDR ranges for db subnets."
}

variable "postgres" {
  default = {
    instance_name      = "dx-ckan-db"
    family             = "postgres11"
    instance_class     = "db.t3.micro"
    instance_version   = "11.19"
    database_name      = "ckan"
    database_user_name = "postgres"
    allocated_storage  = "5"
    backup_retention   = 7
    maintenance_window = "Mon:00:00-Mon:03:00"
    backup_window      = "03:00-06:00"
  }

  type = object({
    instance_name      = string
    family             = string
    instance_class     = string
    database_name      = string
    instance_version   = string
    database_user_name = string
    allocated_storage  = string
    maintenance_window = string
    backup_window      = string
    backup_retention   = number
  })

}

variable "cluster_issuer" {
	type = object({
		private_key = string
		email       = string
	})
}

variable "ckan_storage" {}
variable "cluster_name" {}
