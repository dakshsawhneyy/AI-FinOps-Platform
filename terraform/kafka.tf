# Wait for helm to install strimzi chart, and then start creating CRD resources
resource "time_sleep" "wait_for_strimzi_crds" {
  depends_on = [ helm_release.strimzi ]

  create_duration = "30s"
}

# Kafka Cluster
resource "kubernetes_manifest" "kafka_cluster" {
  # provider = kubernetes.eks_cluster
  depends_on = [ time_sleep.wait_for_strimzi_crds ]

  manifest = {
    "apiVersion" = "kafka.strimzi.io/v1beta2"
    "kind" = "Kafka"
    "metadata" = {
        "name"= "my-kafka-cluster"
        "namespace"= "kafka"
    }
    "spec" = {
        "kafka" = {
            "version" = "3.6.1 "
            "replicas" = 3   # 3 Worker Pods for kafka
            "storage" = {
                "type" = "jbod"   # Just a Bunch of Disks.
                "volumes" = [{
                    "id" = 0
                    "type" = "persistent-claim"    # Go ask aws for 20GB Persistent Volume (EBS)
                    "size" = "20Gi"
                    "deleteClaim" = true   # If i delete this kafka cluster, delete ebs as well
                }]
            }
        }
        # ZooKeeper manages kafka's worker nodes
        "zookeeper" = {
            "replicas" = 3
            "storage" = {
                "type"= "persistent-claim"
                "size"= "10Gi" # 10GB disk for each zookeeper
                "deleteClaim"=  true
            }
        }
    }
  }
}

# Kafka Topic
resource "kubernetes_manifest" "kafka-topic-aicosts" {
  # provider = kubernetes.eks_cluster
  depends_on = [ time_sleep.wait_for_strimzi_crds ]

  manifest = {
    "kind": "KafkaTopic"
    "apiVersion": "kafka.strimzi.io/v1beta2"
    "metadata" = {
        "name"= "ai-costs"
        "namespace"= "kafka"
        "labels" = {
            "strimzi.io/cluster" = "my-kafka-cluster"
        }
    }
    "spec" = {
        "partitions" = 3
        "replicas"   = 3  #  This means our topic's data will be copied to all 3 Kafka brokers. If one broker dies, no data is lost.
    }
  }
}