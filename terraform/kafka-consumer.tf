resource "kubernetes_manifest" "kafka-consumer" {
    provider = kubernetes.eks_cluster
    depends_on = [ kubernetes_manifest.kafka_cluster, kubernetes_manifest.kafka-topic-aicosts ]
    
    manifest = {
        "apiVersion" = "apps/v1"
        "kind" = "Deployment"
        "metadata" = {
            "name"= "kafka-consumer"
            "namespace"= "kafka"
        }
        "spec" = {
            "replicas" = 1
            "selector" = {
                "matchLabels" = {
                    "app" = "kafka-consumer"
                }
            }
            "template" = {
                "metadata" = {
                    "labels" = {
                        "app" = "kafka-consumer"
                    }
                }
                "spec" = {
                    "containers" = [{
                        "name" = "kafka-consumer"
                        "image" = "dakshsawhneyy/kafkaconsumer-python:latest"
                        "ports" = [{
                            "containerPort" = 8000,
                            "name" = "http-metrics"
                        }]
                    }]
                }
            }
        }
    }
}