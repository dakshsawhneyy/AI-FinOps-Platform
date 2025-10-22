# Install Prometheus + Grafana
resource "helm_release" "prometheus" {
  depends_on = [module.eks]
  provider = helm.eks_cluster

  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  # This is the "Aha!" moment from my last message: This one chart installs Prometheus, Grafana, and all the exporters.
  set = [{
    name  = "grafana.enabled"
    value = "true"
  }]
}

# Install OpenCost
resource "helm_release" "opencost" {
  depends_on = [helm_release.prometheus] # Wait for Prometheus to be ready
  provider = helm.eks_cluster

  name       = "opencost"
  repository = "https://opencost.github.io/opencost-helm-chart"
  chart      = "opencost"
  namespace  = "monitoring" # Install it in the same namespace
  create_namespace = false    # Already Created

  set = [{
    name  = "opencost.prometheus.internal.enabled"
    value = "true"
  },
  {
    # This tells OpenCost where to find the Prometheus we just installed
    name  = "opencost.prometheus.external.url"
    value = "http://${helm_release.prometheus.name}-kube-prometheus-prometheus.${helm_release.prometheus.namespace}.svc.cluster.local:9090"
  }]
}