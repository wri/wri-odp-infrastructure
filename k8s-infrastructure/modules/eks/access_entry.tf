# Bound to the dev-only `eks-admin` IAM role (see modules/eks/iam.tf). In prod
# cluster-admin access goes through Access Entries on `var.cluster_admin_role_arns`
# (SSO admin + GitHub Actions OIDC role), so this entry is gated to dev.
resource "aws_eks_access_entry" "admins" {
  count = local.create_eks_admin_chain ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = module.eks_admins_iam_role[0].iam_role_arn
  user_name     = module.eks_admins_iam_role[0].iam_role_name
  type          = "STANDARD"

  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "admins" {
  count = local.create_eks_admin_chain ? 1 : 0

  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = module.eks_admins_iam_role[0].iam_role_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admins
  ]
}

data aws_iam_roles admin_arn {
  name_regex = "^AWSReservedSSO_AWSAdministratorAccess_(?P<slug>[0-9a-f]{16})$$"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

resource "aws_eks_access_entry" "admin_role" {
  for_each = data.aws_iam_roles.admin_arn.arns

  cluster_name  = var.cluster_name
  principal_arn = each.value
  type          = "STANDARD"

  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "admin_policy" {
  for_each = data.aws_iam_roles.admin_arn.arns

  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admin_role
  ]
}