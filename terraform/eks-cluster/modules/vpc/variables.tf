variable "aws_region" {
  description = "AWS region to deploy EKS"
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "VPC name"
  default     = "vpc-devops-project-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "Private subnets CIDR blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnets CIDR blocks"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}