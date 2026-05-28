
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  name                            = var.cluster_name
  authentication_mode             = "API_AND_CONFIG_MAP"
  endpoint_private_access         = true
  endpoint_public_access          = true
  kubernetes_version              = var.kubernetes_version
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  enable_irsa                     = true

  addons = {
    vpc-cni = {
      most_recent                 = true
      resolve_conflicts_on_create  = "OVERWRITE"
      # Install the VPC CNI before the managed node group is created so the
      # first node has a working pod network and can reach Ready.
      before_compute = true
    },
    kube-proxy = {
      most_recent                 = true
      resolve_conflicts_on_create  = "OVERWRITE"
      before_compute = true
    },
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_create  = "OVERWRITE"
    }
  }

  iam_role_additional_policies = {
    eks_vpccontroller = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }

  # We explicitly enumerate admins via cluster_admin_role_arns so the set of
  # cluster admins is independent of which principal happens to run Terraform.
  enable_cluster_creator_admin_permissions = false

  access_entries = {
    for arn in var.cluster_admin_role_arns : "admin-${md5(arn)}" => {
      principal_arn = arn
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    one = {
      name           = "node-group-1"
      instance_types = ["t3.xlarge"]
      use_latest_ami_release_version = false

      min_size     = 1
      max_size     = 6
      desired_size = 6

      enable_monitoring = true

      force_update_version = true

      #timeouts = {
      #  update = "240m"
      #}

      attach_cluster_primary_security_group = true
      create_security_group                 = false

      iam_role_additional_policies = {
        cni_policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        # Enables SSM Session Manager into nodes for `journalctl -u kubelet`
        # debugging when a node fails to join.
        ssm_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }
  tags = {
    Environment = var.project_env
  }
}

# exec-only auth (see the rationale in helm.tf): a saved plan applied in a
# separate job can't use a static EKS token because it expires in 15 minutes.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

output "eks_oidc" {
  value = module.eks.oidc_provider_arn
}

output "aws_eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "aws_eks_cluster_name" {
  value = module.eks.cluster_name
}
