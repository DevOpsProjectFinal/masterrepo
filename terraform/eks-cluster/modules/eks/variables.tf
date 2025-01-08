variable "aws_region" {
  description = "AWS region to deploy EKS"
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS cluster to test deployments for multiple services"
  default     = "devops-project-eks-cluster"
}

variable "cluster_version" {
  description = "EKS Cluster version"
  default     = "1.31"
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

variable "cluster_security_group_id" {
  description = "The ID of the security group to use for the EKS cluster"
  type        = string
  default     = "sg-devops-project-eks-cluster"
}

variable "create_node_sg" {
  description = "Whether to create a new security group for the nodes"
  type        = bool
  default     = true
}

variable "node_security_group_id" {
  description = "The ID of the security group to use for the nodes"
  type        = string
  default     = "ng-devops-project-eks-cluster"
}