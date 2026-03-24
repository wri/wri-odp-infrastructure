terraform {
  backend "s3" {
    bucket         = "wri-odp-tfm-state-bucket"
    dynamodb_table = "tfm-state-lock"
    key            = "global/statefile/terraform.state"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "wri-aws-terraform"
}

module "infrastructure" {
  source                     = "../../k8s-infrastructure"
  availability_zones         = var.availability_zones
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  sg_rds_cidr_block          = var.sg_rds_cidr_block
  db_subnet_cidr_blocks      = var.db_subnet_cidr_blocks
  project_env                = var.project_env
  postgres                   = var.postgres
  ckan_storage               = var.s3_ckan_storage
  cluster_name               = var.s3_cluster_name
  cluster_issuer             = var.cluster_issuer
  bucket_names               = var.bucket_names
  ecr_repositories           = var.ecr_repositories
  csi_driver_addon_version   = var.csi_driver_addon_version
}



