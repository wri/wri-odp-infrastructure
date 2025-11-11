resource "aws_eks_access_entry" "admins" {
  cluster_name  = var.cluster_name
  principal_arn = module.eks_admins_iam_role.iam_role_arn
  user_name     = module.eks_admins_iam_role.iam_role_name
  kubernetes_groups = [
    "system:masters",
  ]

  depends_on = [module.eks]
}


