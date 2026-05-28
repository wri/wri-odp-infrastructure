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

# Regex-driven SSO admin discovery. This was the original mechanism for
# granting the SSO admin role cluster access. It is now duplicated by the EKS
# module's `access_entries` block in main.tf (which loops over
# `var.cluster_admin_role_arns` and creates an entry per ARN). When the caller
# opts into the explicit list, skip the regex-driven entries to avoid
# `ResourceInUseException: access entry resource is already in use`.
#
# Dev currently does not pass `cluster_admin_role_arns`, so the for_each here
# still discovers the SSO role and keeps its existing entry untouched.
locals {
  use_regex_admin_entries = length(var.cluster_admin_role_arns) == 0
}

resource "aws_eks_access_entry" "admin_role" {
  for_each = local.use_regex_admin_entries ? data.aws_iam_roles.admin_arn.arns : toset([])

  cluster_name  = var.cluster_name
  principal_arn = each.value
  type          = "STANDARD"

  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "admin_policy" {
  for_each = local.use_regex_admin_entries ? data.aws_iam_roles.admin_arn.arns : toset([])

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