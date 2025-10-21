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