resource "kubernetes_config_map_v1" "producer_script" {
  provider = kubernetes.eks_cluster

  metadata {
    name = "producer-script"
    namespace = "kafka"
  }

  data = {
    "kafka-producer.sh" = file("${path.module}/kafka-producer.sh")
  }
}