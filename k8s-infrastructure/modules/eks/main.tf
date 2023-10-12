
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.25"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  enable_irsa                     = true
  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    attach_cluster_primary_security_group = true
    # Disabling and using externally provided security groups
    create_security_group = false
  }

  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = ["t3.xlarge"]

      min_size     = 1
      max_size     = 5
      desired_size = 3
    }
  }
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_role_name
      groups   = ["system:masters"]
    },
  ]
  tags = {
    Environment = var.project_env
  }
}


data "aws_eks_cluster" "default" {
  #name = module.eks.cluster_name
  name = var.cluster_name
  #depends_on = [module.eks.cluster_name]
}

data "aws_eks_cluster_auth" "default" {
  #name = module.eks.cluster_name
  name = var.cluster_name
  #depends_on = [module.eks.cluster_name]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token

  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

output "eks_oidc" {
  value = module.eks.oidc_provider_arn
}

output "aws_eks_cluster" {
  value = data.aws_eks_cluster.default
}

output "aws_eks_cluster_auth" {
  value = data.aws_eks_cluster_auth.default
}
