module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}"
  cidr = "${var.vpc_cidr}"

  count = terraform.workspace == "aws" ? 1 : 0

  azs = local.azs
  public_subnets = local.public_subnets
  private_subnets = local.private_subnets

  # Enable NAT gateway
  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  # Internet Gateway
  create_igw = true

  # This tells the public subnets to automatically assign a public IP to any instance launched in them.
  map_public_ip_on_launch = true 
}

# =============================================================================
# EKS CLUSTER CONFIGURATION
# =============================================================================
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  # Basic cluster configuration
  cluster_name    = var.project_name
  cluster_version = var.kubernetes_version

  # Cluster access configuration
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  enable_cluster_creator_admin_permissions = true

  # EKS Auto Mode configuration - simplified node management
  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

#   eks_managed_node_groups = {
#     general = {
#       instance_types = ["t2.micro"]
#       min_size       = 1
#       max_size       = 3
#       desired_size   = 2
#       vpc_security_group_ids = [aws_security_group.web_sg.id]
#     }
#   }

  # Network configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # KMS configuration to avoid conflicts
  create_kms_key = true
  kms_key_description = "EKS cluster ${var.project_name} encryption key"
  kms_key_deletion_window_in_days = 7
  
  # Cluster logging (optional - can be expensive)
  cluster_enabled_log_types = []

  tags = local.common_tags
}