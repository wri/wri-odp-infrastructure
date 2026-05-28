# Look up the most-recent EBS CSI driver build that is compatible with the
# cluster's Kubernetes version. Used when `csi_driver_addon_version` is left
# empty so the addon doesn't break when the cluster K8s version is bumped (a
# pinned build like v1.32.0-eksbuild.1 is not supported on K8s 1.35).
data "aws_eks_addon_version" "csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "csi_driver" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-ebs-csi-driver"
  addon_version = (
    var.csi_driver_addon_version != "" ?
    var.csi_driver_addon_version :
    data.aws_eks_addon_version.csi_driver.version
  )
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}