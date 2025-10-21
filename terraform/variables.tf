variable "project_name" {
  type = string
  default = "AI-FinOps-Platform"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  type = bool
  default = true
}

variable "environment" {
  type = string
  default = "dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
}

variable "aws_region" {
  type = string
  default = "ap-south-1"
}