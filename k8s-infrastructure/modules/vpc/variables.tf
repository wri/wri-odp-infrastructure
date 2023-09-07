variable "project_env" {
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name for the infrastructure."
}

variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "A valid AWS region to configure the underlying AWS SDK."
}

variable "cidr_block" {
  default     = "10.0.0.0/16" // 10.0.0.0 - 10.0.255.255
  type        = string
  description = "The CIDR range for the entire VPC."
}

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

variable "cluster" {
  default = {
  name = "ckan-dev-cluster-test" }
  type = object({
    name = string
  })
}