terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm ={
      source  = "hashicorp/helm"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# data "aws_eks_cluster" "eks" {
#   depends_on = [ module.eks.cluster_id ]
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "eks" {
#   depends_on = [ module.eks.cluster_id ]
#   name = module.eks.cluster_name
# }

provider "kubernetes" {
  alias = "eks_cluster"   # dummy provider so Terraform doesn't fail at plan time because eks cluster hasn't built yet
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
  
  # Explicitely mentioning path
  # config_path = "~/.kube/config" # Explicit path
}

provider "helm" {
  alias = "eks_cluster"
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }

    # config_path = "~/.kube/config" # Explicit path
  }
}