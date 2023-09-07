module "ckan_vpc" {
  source = "./modules/vpc"
  project_env = var.project_env
  cluster_name = var.cluster_name
  availability_zones             = var.availability_zones
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks       = var.public_subnet_cidr_blocks
  db_subnet_cidr_blocks = var.db_subnet_cidr_blocks
}

module "ckan_eks" {
  source                = "./modules/eks"
  cluster_name          = var.cluster_name
  vpc_id                = module.ckan_vpc.vpc_id
  subnet_ids            = module.ckan_vpc.subnet_ids
  aws_security_group_id = module.ckan_vpc.security_group_id
  vpc_owner_id          = module.ckan_vpc.owner_id
  cluster_issuer        = var.cluster_issuer
  project_env = var.project_env

}

module "ckan_rds" {
  source                = "./modules/rds"
  db_subnet_group       = module.ckan_vpc.db_subnet_group
  security_group_rds_id = module.ckan_vpc.security_group_rds_id
  postgres              = var.postgres
  depends_on = [module.ckan_vpc]
}

module "ckan_storage" {
  source       = "./modules/s3"
  storage      = var.ckan_storage
  cluster_name = var.cluster_name

}

module "ckan_ecr" {
  source = "./modules/ecr"
  cluster_name = var.cluster_name
}

