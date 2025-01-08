variable "aws_region" {
  description = "AWS region to deploy EKS"
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS cluster to test deployments for multiple services"
  default     = "devops-project-eks-cluster"
}

variable "fargate_profiles" {
  description = "Map of Fargate profiles to create"
  default = {
    default = {
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
    }
  }
}