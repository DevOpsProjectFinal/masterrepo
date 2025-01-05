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
  description = "EKS cluster to test deployments for multiple services"
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

variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be created"
  type        = string
}

variable "subnets" {
  description = "The subnets where the EKS cluster will be created"
  type        = list(string)
}

variable "create_cluster_security_group" {
  description = "Flag to determine if a new cluster security group should be created"
  type        = bool
  default     = true
}

variable "create_node_security_group" {
  description = "Flag to determine if a new node security group should be created"
  type        = bool
  default     = true
}

variable "cluster_security_group_id" {
  description = "The ID of the cluster security group"
  type        = string
  default     = null
}

variable "node_security_group_id" {
  description = "The ID of the node security group"
  type        = string
  default     = null
}

variable "principals" {
  description = "List of principals to include in the IAM policy"
  type        = list(string)
  default     = []
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "796973482644"
}

variable "key_id" {
  description = "KMS key ID"
  type        = string
  default     = "3738e835-3372-4ad1-8150-59d641b761bf"
}