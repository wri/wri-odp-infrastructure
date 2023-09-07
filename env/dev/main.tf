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
  region = var.aws_region
}

module "infrastructure" {
  source                     = "../../k8s-infrastructure"
  availability_zones         = var.availability_zones
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  db_subnet_cidr_blocks      = var.db_subnet_cidr_blocks
  project_env                = var.project_env
  postgres                   = var.postgres
  ckan_storage               = var.s3_ckan_storage
  cluster_name               = var.s3_cluster_name
  cluster_issuer             = var.cluster_issuer
}



