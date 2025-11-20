resource "aws_eks_access_entry" "admins" {
  cluster_name  = var.cluster_name
  principal_arn = module.eks_admins_iam_role.iam_role_arn
  user_name     = module.eks_admins_iam_role.iam_role_name
  kubernetes_groups = [
    "system:masters",
  ]

  depends_on = [module.eks]
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
