# VPC for the cluster
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  name = var.project_name
  cidr = "10.0.0.0/16"
  
  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  
  tags = {
    Project = var.project_name
    Environment = "demo"
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.project_name
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    standard = {
      desired_size = 3
      min_size     = 2
      max_size     = 5
      
      instance_types = ["t3.small"]
      
      labels = {
        workload = "standard"
      }
    }
    
    # GPU node group removed due to AWS quota constraints
    # Platform supports GPU monitoring - demo uses simulated metrics
  }

  tags = {
    Project = var.project_name
  }
}