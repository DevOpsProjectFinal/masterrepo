variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the instance profile for Karpenter-managed nodes"
  type        = string
}

variable "eks_certificate_data" {
  description = "CA"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets for worker nodes"
  type        = list(string)
  default     = []
}