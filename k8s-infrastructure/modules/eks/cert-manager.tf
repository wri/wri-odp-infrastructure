# cert-manager and the Let's Encrypt ClusterIssuer used to be installed via the
# `terraform-iaac/cert-manager/kubernetes` module, but that module pulls in the
# `alekc/kubectl` provider, which fails its configuration validation at plan
# time during a fresh EKS bootstrap (the cluster endpoint, CA, and auth token
# are still "known after apply").
#
# The helm provider does not have that limitation, so we install cert-manager
# directly from the upstream Jetstack chart and apply the ClusterIssuer through
# a small in-repo chart at ./charts/cluster-issuer. Defaults below match the
# behaviour of `terraform-iaac/cert-manager` v3.0.1 so this is a drop-in
# replacement.

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.17.2"

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
    {
      name  = "crds.keep"
      value = "true"
    },
  ]
}

# Give the cert-manager webhook a moment to come up before submitting the
# ClusterIssuer; otherwise the validating webhook can reject the apply.
resource "time_sleep" "wait_for_cert_manager" {
  create_duration = "60s"

  depends_on = [helm_release.cert_manager]
}

resource "helm_release" "cluster_issuer" {
  name      = "cluster-issuer"
  namespace = "cert-manager"
  chart     = "${path.module}/charts/cluster-issuer"

  values = [yamlencode({
    name           = "cert-manager"
    server         = "https://acme-v02.api.letsencrypt.org/directory"
    preferredChain = "ISRG Root X1"
    email          = var.cluster_issuer.email
    privateKeySecretRef = {
      name = "cert-manager-private-key"
    }
    solvers = [
      {
        http01 = {
          ingress = {
            class = "nginx"
          }
        }
      },
    ]
  })]

  depends_on = [time_sleep.wait_for_cert_manager]
}
