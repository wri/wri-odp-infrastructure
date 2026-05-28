provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.default.token
    exec = {
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
  name             = "nginx-ingress-production"
  chart            = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  namespace        = "nginx-ingress"
  create_namespace = true

  set = [{
    name  = "rbac.create"
    value = true
    },
    {
      name  = "controller.service.externalTrafficPolicy"
      value = "Local"
    },
    {
      name  = "controller.publishService.enabled"
      value = true
    },
    {
      name  = "controller.replicaCount"
      value = "3"
  }]
}


variable "cluster_issuer" {
  type = object({
    #private_key = string
    email = string
  })
}

# cert-manager + ClusterIssuer are defined in cert-manager.tf.
