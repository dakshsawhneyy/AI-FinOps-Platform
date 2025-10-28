# Pod for kafka-consumer
resource "kubernetes_manifest" "kafka-consumer" {
    # provider = kubernetes.eks_cluster
    # depends_on = [ kubernetes_manifest.kafka_cluster, kubernetes_manifest.kafka-topic-aicosts ]
    
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


# Service for Kafka-Consumer
resource "kubernetes_manifest" "kafka-consumer-service" {
    # provider = kubernetes.eks_cluster
    # depends_on = [ kubernetes_manifest.kafka-consumer ]

    manifest = {
        "apiVersion" = "v1"
        "kind" = "Service"
        "metadata" = {
            "name" = "kafka-consumer-metrics"
            "namespace" = "kafka"
            "labels" = {
                "app" = "kafka-consumer"
            }
        }
        "spec" = {
            "selector" = {
                "app" = "kafka-consumer"
            }
            "ports" = [{
                "name"       = "http-metrics"
                "port"       = 8000 # The port the Service will listen on
                "targetPort" = 8000 # The port the Pod's container listens on (from your Python script)
            }]
        }
    }
}