module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"
  name    = "${var.cluster_name}-vpc"

  cidr = var.cidr_block

  azs                    = var.availability_zones
  private_subnets        = var.private_subnet_cidr_blocks
  public_subnets         = var.public_subnet_cidr_blocks
  database_subnets       = var.db_subnet_cidr_blocks
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # Common for many AWS Services to require DNS (e.g. EFS Filesystem in EKS CLuster)
  enable_dns_support   = true
  enable_dns_hostnames = true
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  tags = {
    Environment = var.project_env
  }

}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "ckan_db"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

output "db_subnet_group" {
  value = module.vpc.database_subnet_group
}

output "security_group_rds_id" {
  value = aws_security_group.rds.id
}

output "security_group_id" {
  value = aws_security_group.node_group_one.id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = module.vpc.private_subnets
}

output "owner_id" {
  value = module.vpc.vpc_owner_id
}