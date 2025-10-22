output "EKS_Cluster_Name" {
  value = module.eks.cluster_name
}

output "EKS_Cluster_ARN" {
  value = module.eks.cluster_arn
}

output "EKS_Node_Groups" {
  value = module.eks.eks_managed_node_groups
}

output "EKS_CLUSTER_ENDPOINT" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}