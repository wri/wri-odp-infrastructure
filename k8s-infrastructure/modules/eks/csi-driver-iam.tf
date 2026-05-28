data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  # IAM role names are global per AWS account. Dev created `eks-ebs-csi-driver`
  # first; keep that exact name in dev for backward compatibility, and suffix
  # any other environment so each cluster gets its own role bound to its own
  # OIDC issuer without colliding.
  name = var.project_env == "dev" ? "eks-ebs-csi-driver" : "eks-ebs-csi-driver-${var.project_env}"
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
