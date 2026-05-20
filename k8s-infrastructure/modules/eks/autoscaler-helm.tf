data "aws_region" "current" {}

# Cluster Autoscaler is deployed via the official Helm chart instead of raw
# manifests so the helm provider can defer auth resolution until apply time.
# The alekc/kubectl provider validates its configuration during plan and fails
# during the initial bootstrap when the EKS endpoint/CA/token are still
# "known after apply".
#
# Chart 9.46.6 ships appVersion 1.32.0; image.tag is pinned to keep parity
# with the previously deployed v1.32.3 image.
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.46.6"

  values = [yamlencode({
    autoDiscovery = {
      clusterName = module.eks.cluster_name
    }
    awsRegion = data.aws_region.current.region

    image = {
      tag = "v1.32.3"
    }

    rbac = {
      serviceAccount = {
        create = true
        name   = "cluster-autoscaler"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.cluster_autoscaler_irsa_role.iam_role_arn
        }
      }
    }

    extraArgs = {
      v                               = 4
      stderrthreshold                 = "info"
      "skip-nodes-with-local-storage" = false
      expander                        = "least-waste"
    }

    priorityClassName = "system-cluster-critical"

    resources = {
      limits = {
        cpu    = "100m"
        memory = "600Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "600Mi"
      }
    }
  })]
}
