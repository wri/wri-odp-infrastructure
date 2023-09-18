provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "sealed-secrets"
}

resource "helm_release" "ngnix_ingress" {
  name       = "nginx-ingress-production"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "nginx-ingress"
  version    = "4.4.0"

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.publishService.enabled"
    value = true
  }

  set {
    name  = "controller.replicaCount"
    value = "3"
  }
}


variable "cluster_issuer" {
  type = object({
    private_key = string
    email       = string
  })
}

module "cert_manager" {
  source                                 = "terraform-iaac/cert-manager/kubernetes"
  version                                = "2.6.0"
  cluster_issuer_email                   = var.cluster_issuer.email
  cluster_issuer_private_key_secret_name = var.cluster_issuer.private_key
}
