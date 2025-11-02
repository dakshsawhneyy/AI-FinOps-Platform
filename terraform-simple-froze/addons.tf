# Install Prometheus + Grafana
resource "helm_release" "prometheus" {
  depends_on = [module.eks.cluster_id]
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

# Install Strimzi (Kubernetes Operator)
resource "helm_release" "strimzi" {
  depends_on = [ module.eks.cluster_id ]
  provider = helm.eks_cluster

  name = "strimzi-kafka-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  namespace  = "kafka" # Or your desired namespace for Strimzi
  create_namespace = true

  version = "0.36.0"    # modern Strimzi operator version (0.28.0+ for KRaft)

  # Also enable critical feature gates (KRaft and KafkaNodePools)
  set = [ {
    name = "clusterOperator.featureGates"
    value = "{UseKRaft,KafkaNodePools}"
  } ]
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
    name  = "opencost.prometheus.external.enabled"
    value = "true"
  },
  {
    # This tells OpenCost where to find the Prometheus we just installed
    name  = "opencost.prometheus.external.url"
    value = "http://${helm_release.prometheus.name}-prometheus.${helm_release.prometheus.namespace}.svc.cluster.local:9090"
  },{
    name  = "opencost.prometheus.internal.enabled"
    value = "false"
  }]
}