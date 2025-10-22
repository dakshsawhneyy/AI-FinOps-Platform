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

data "aws_eks_cluster" "eks" {
  depends_on = [ module.eks ]
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  depends_on = [ module.eks ]
  name = module.eks.cluster_name
}

provider "kubernetes" {
  alias = "eks_cluster"   # dummy provider so Terraform doesn't fail at plan time because eks cluster hasn't built yet
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_certificate_authority[0].data)
  token                   = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  alias = "eks_cluster"
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}