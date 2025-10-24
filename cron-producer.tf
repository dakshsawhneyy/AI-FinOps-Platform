# Not using Cron --- Using deployment for now

# This is our "log generator." We are using the SIMPLE "kubernetes_manifest" resource.
resource "kubernetes_manifest" "cost_producer" {
  provider = kubernetes.eks_cluster
  depends_on = [kubernetes_manifest.kafka-topic]

  manifest = {
    "apiVersion" = "batch/v1"
    "kind"       = "CronJob"
    "metadata" = {
      "name"      = "cost-producer"
      "namespace" = "kafka"
    }
    "spec" = {
      # "Alarm clock" setting: run every minute
      "schedule" = "*/1 * * * *"
      
      "jobTemplate" = {
        "spec" = {
          "template" = {
            "spec" = {
              "containers" = [{
                  "name"  = "producer"
                  "image" = "bitnami/kafka:3.6"
                  "command" = [
                    "/bin/sh",
                    "-c"
                  ]
                  "args" = [
                    "JSON_MSG={\"event_id\": \"evt_gpu_$(($RANDOM % 1000))\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S)\", \"source\": \"gpu_job\", \"cost\": $(($RANDOM % 5 + 1)).$(($RANDOM % 99)), \"details\": {\"team\": \"ml-team\", \"duration_seconds\": 180}} && " +
                    "echo $JSON_MSG | " +
                    "/opt/bitnami/kafka/bin/kafka-console-producer.sh " +   # THe tool used to send log message to kafka cluster
                    "--broker-list my-kafka-cluster-kafka-brokers.kafka.svc.cluster.local:9092 " +    # Address of the cluster
                    "--topic ai-costs;"    # Specifying the topic
                  ]
                }]
              
              "restartPolicy" = "OnFailure"
            }
          }
        }
      }
    }
  }
}

