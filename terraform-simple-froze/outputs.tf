output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "grafana_url" {
  value = "Get from: kubectl get svc -n monitoring monitoring-grafana"
}

output "opencost_url" {
  value = "Get from: kubectl get svc -n opencost opencost-ui"
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}