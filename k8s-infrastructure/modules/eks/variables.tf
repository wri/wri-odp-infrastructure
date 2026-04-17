variable "cluster_name" {
  default = "ckan-dev-cluster"
}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "project_env" {}
variable "vpc_owner_id" {}

variable "csi_driver_addon_version" {}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster."
  default     = "1.35"
}