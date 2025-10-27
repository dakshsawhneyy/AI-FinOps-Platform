resource "kubernetes_manifest" "cost_producer" {
  # provider = kubernetes.eks_cluster
  depends_on = [ kubernetes_manifest.kafka-topic-aicosts, kubernetes_config_map_v1.producer_script ]

  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
        "name"= "cost-producer"
        "namespace"= "kafka"
    }
    "spec" = {
        "replicas" = 1
        "selector" = {
            "matchLabels" = {
                "app" = "cost-producer"
            }
        }
        "template" = {
            "metadata" = {
                "labels" = {
                    "app" = "cost-producer"
                }
            }
            "spec" = {
                # Specifying config map's script
                "volumes" = [{
                    "name": "script-volume"
                    "configMap" = {
                        "name" = kubernetes_config_map_v1.producer_script.metadata[0].name
                        "defaultMode" = 493
                    }
                }]
                "containers" = [{
                    "name" = "cost-producer"
                    "image" = "apache/kafka:latest"
                    # Mount the volume into the container
                    "volumeMounts" = [{
                        "name" = "script-volume"
                        "mountPath" = "/app"
                        "readOnly" = true
                    }]
                    "command" = ["/app/kafka-producer.sh"]
                    "args" = null
                }]
                "restartPolicy" = "Always"
            }
        }
    }
  }
}