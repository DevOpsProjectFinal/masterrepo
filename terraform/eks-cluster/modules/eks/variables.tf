variable "aws_region" {
  description = "AWS region to deploy EKS"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster to test deployments for multiple services"
  default     = "devops-project-eks-cluster"
}

variable "cluster_version" {
  description = "EKS Cluster version"
  default     = "1.31"
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

# modules/eks/variables.tf
variable "control_plane_subnet_ids" {
  description = "List of subnets for the control plane (optional)"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnets for worker nodes"
  type        = list(string)
  default     = []
}

variable "aws_account_id" {
  description = "List of subnets for worker nodes"
  default     = 796973482644
}