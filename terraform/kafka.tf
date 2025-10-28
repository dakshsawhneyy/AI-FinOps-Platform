# resource "time_sleep" "wait_for_strimzi" {
#   depends_on = [ helm_release.strimzi ]
#   create_duration = "30s"
# }

# # Kafka Cluster
# resource "kubernetes_manifest" "kafka_cluster" {
#   # provider = kubernetes.eks_cluster
#   depends_on = [ time_sleep.wait_for_strimzi ]

#   manifest = {
#     "apiVersion" = "kafka.strimzi.io/v1beta2"
#     "kind" = "Kafka"
#     "metadata" = {
#         "name"= "my-kafka-cluster"
#         "namespace"= "kafka"
#     }
#     "spec" = {
#         "kafka" = {
#             "version" = "4.0.0"
#             "nodePools" = [{
#                 "name" = "kafka" # Pool name (must exist, named 'kafka' here)
#                 "roles" = [
#                     "broker",    # Act as brokers
#                     "controller" # Act as KRaft controllers
#                 ]
#                 "replicas" = 3       # 3 nodes in this pool
#                 "storage" = {
#                     "type"        = "persistent-claim" # Use persistent storage
#                     "size"        = "20Gi"
#                     "deleteClaim" = true
#                 }
#             }]
#             # we didn't specified how producer consumer connect to kafka broker -- listeners does this task
#             "listeners" = [{
#                 "name" = "plain" # Give the listener a name
#                 "port" = 9092     # Standard Kafka port
#                 "type" = "internal" # Only accessible within the Kubernetes cluster
#                 "tls"  = false    # Disable TLS encryption for this internal listener
#             },{
#                 "name" = "controller" 
#                 "port" = 9093     
#                 "type" = "internal" 
#                 "tls"  = false    
#             }]
#         }
#         "featureGates" = {
#             "UseKRaft" = "Enabled"
#         }
#     }
#   }
# }


# # Kafka Topic
# resource "kubernetes_manifest" "kafka-topic-aicosts" {
#   # provider = kubernetes.eks_cluster
#   depends_on = [ kubernetes_manifest.kafka_cluster ]

#   manifest = {
#     "kind": "KafkaTopic"
#     "apiVersion": "kafka.strimzi.io/v1beta2"
#     "metadata" = {
#         "name"= "ai-costs"
#         "namespace"= "kafka"
#         "labels" = {
#             "strimzi.io/cluster" = "my-kafka-cluster"
#         }
#     }
#     "spec" = {
#         "partitions" = 3
#         "replicas"   = 3  #  This means our topic's data will be copied to all 3 Kafka brokers. If one broker dies, no data is lost.
#     }
#   }
# }