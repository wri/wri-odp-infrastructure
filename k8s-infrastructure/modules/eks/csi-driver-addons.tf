resource "aws_eks_addon" "csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.22.0-eksbuild.2"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}