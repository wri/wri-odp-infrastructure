variable "aws_region" {
  default = "us-east-1"
}
variable "s3_ckan_storage" {
  default = "storage"
}
variable "s3_cluster_name" {
  default = "ckan-prod"
}

variable "postgres" {
  default = {
    instance_name         = "dx-ckan-db-prod"
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

variable "project_env" {
  default = "prod"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "A list of availability zones for subnet placement."
}


variable "private_subnet_cidr_blocks" {
  # /20 (~4091 usable IPs each) so the VPC CNI warm-IP pool on
  # t3.xlarge node groups doesn't exhaust the subnet. The previous /24s
  # only had ~251 IPs each, which causes NodeCreationFailure when a few
  # nodes are launched per AZ.
  default     = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
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
  default = ["ckan-prod-storage"]
}

variable "ecr_repositories" {
  type    = list(string)
  default = []
}

variable "csi_driver_addon_version" {
  # Empty string => auto-resolve the most-recent build compatible with the
  # cluster's Kubernetes version (see modules/eks/csi-driver-addons.tf). Pin a
  # specific build here only if you need to freeze the addon version.
  default = ""
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster."
  default     = "1.35"
}

variable "cluster_admin_role_arns" {
  type        = list(string)
  description = "IAM role ARNs to grant cluster-admin on the EKS cluster via Access Entries."
  default = [
    # SSO admin role used by humans for break-glass kubectl access.
    # Update the random suffix if AWS Identity Center is recreated.
    "arn:aws:iam::245948672511:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_69d61212ea5659d4",
    # GitHub Actions OIDC role used by CI to deploy to the cluster.
    "arn:aws:iam::245948672511:role/github-actions-oidc-role",
  ]
}