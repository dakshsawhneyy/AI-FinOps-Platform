resource "kubernetes_manifest" "kafka-consumer-servicemonitor" {
  # provider = kubernetes.eks_cluster
  depends_on = [ kubernetes_manifest.kafka-consumer-service ]

  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "name"      = "kafka-consumer-monitor" 
      "namespace" = "monitoring"             # IMPORTANT: Must be in same namespace as Prometheus
      "labels" = {
        "release" = "kube-prometheus-stack" # Assumes default Helm release name was "kube-prometheus-stack" (reqd. as there can be multiple prometheus operators)
      }
    }
    "spec" = {
        "selector" = {
            "matchLabels" = {
                "app" = "kafka-consumer"
            }
        }
        # Which namespace(s) to look for the Service in
        "namespaceSelector" = {
            "matchNames" = [
                "kafka" # Look in the 'kafka' namespace
            ]
        }
        # Which port on the Service endpoint to scrape
        "endpoints" = [
            {
            "port" = "http-metrics" # Match the 'name' of the port in our Service manifest
            "interval" = "15s" # Optional: How often to scrape (default is usually 30s)
            }
        ]
    }
  }
}