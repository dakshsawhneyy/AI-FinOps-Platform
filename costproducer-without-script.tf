resource "kubernetes_manifest" "cost_producer" {
  provider = kubernetes.eks_cluster
  depends_on = [ kubernetes_manifest.kafka-topic-aicosts ]

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
                "containers" = [{
                    "name" = "cost-producer"
                    "image" = "bitnami/kafka:3.6"
                    "command" = [
                        "/bin/sh",
                        "-c",
                    ]

                    "args" = [
                        # "while true; do " + 
                        # "JSON_MSG={\"event_id\": \"evt_gpu_$(($RANDOM % 1000))\", \"timestamp\": \"$(date +\"%Y-%m-%dT%H:%M:%S\")\", \"source\": \"gpu_job\", \"cost\": $(($RANDOM % 5 + 1)).$(($RANDOM % 99)), \"details\": {\"team\": \"ml-team\", \"duration_seconds\": 180}}; " +
                        # "echo $JSON_MSG | " +
                        # "/opt/bitnami/kafka/bin/kafka-console-producer.sh " +
                        # "--broker-list my-kafka-cluster-kafka-brokers.kafka.svc.cluster.local:9092 " +
                        # "--topic ai-costs; " +
                        # "sleep 10; " +
                        # "done"

                        # Need to write all this in a single line
                        "while true; do JSON_MSG={\"event_id\": \"evt_gpu_$(($RANDOM % 1000))\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"source\": \"gpu_job\", \"cost\": $(($RANDOM % 5 + 1)).$(($RANDOM % 99)), \"details\": {\"team\": \"ml-team\", \"duration_seconds\": 180}}; echo $JSON_MSG | /opt/bitnami/kafka/bin/kafka-console-producer.sh --broker-list my-kafka-cluster-kafka-brokers.kafka.svc.cluster.local:9092 --topic ai-costs; sleep 10; done"
                    ]
                }]
                "restartPolicy" = "Always"
            }
        }
    }
  }
}