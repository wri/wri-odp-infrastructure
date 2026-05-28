module "cluster_autoscaler_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1"

  # IAM role names are global per AWS account. Dev owns `cluster-autoscaler`;
  # suffix per-env so each cluster's autoscaler IRSA role is independent.
  role_name                        = var.project_env == "dev" ? "cluster-autoscaler" : "cluster-autoscaler-${var.project_env}"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}