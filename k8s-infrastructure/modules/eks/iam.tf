locals {
  # The eks-admin assume-role chain (the `eks-admin` IAM role, the `wri-odp-dev`
  # IAM group, and the two helper policies below) only exists to support the dev
  # workflow where engineers assume `eks-admin` from their personal IAM user.
  #
  # In prod, cluster-admin access is granted directly via EKS Access Entries on
  # the SSO admin role and the GitHub Actions OIDC role (see
  # `var.cluster_admin_role_arns`), so this chain isn't used. Because IAM names
  # are global per AWS account, also creating them from the prod state would
  # collide with the dev-owned resources. Scope them to dev to keep names unique.
  create_eks_admin_chain = var.project_env == "dev"
}

module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  count = local.create_eks_admin_chain ? 1 : 0

  name          = "allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  count = local.create_eks_admin_chain ? 1 : 0

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_eks_access_iam_policy[0].arn]

  trusted_role_arns = [
    "arn:aws:iam::${var.vpc_owner_id}:root"
  ]
}

/* module "dev_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.3.1"

  name                          = "dev1-datopian"
  create_iam_access_key         = false
  create_iam_user_login_profile = false

  force_destroy = true
} */

module "allow_assume_eks_admins_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  count = local.create_eks_admin_chain ? 1 : 0

  name          = "allow-assume-eks-admin-iam-role"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.eks_admins_iam_role[0].iam_role_arn
      },
    ]
  })
}

module "eks_dev_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.3.1"

  count = local.create_eks_admin_chain ? 1 : 0

  name                              = "wri-odp-dev"
  attach_iam_self_management_policy = false
  create_group                      = true
  #group_users                       = [module.dev_iam_user.iam_user_name]
  custom_group_policy_arns = [module.allow_assume_eks_admins_iam_policy[0].arn]
  tags = {
    Description = "This group is managed by terraform for granting access to the devs to the k8s cluster"
  }
}
