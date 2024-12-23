# variables.tf

variable "aws_region" {
  description = "AWS region to deploy EKS"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  description = "Private subnets CIDR blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnets CIDR blocks"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "my-first-eks-cluster"
}

variable "node_group_size" {
  description = "The desired size of the node group"
  default     = 2
}

variable "instance_type" {
  description = "The EC2 instance type for the worker nodes"
  default     = "t3.medium"
}
