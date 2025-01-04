provider "aws" {
  region = var.aws_region
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "eks-vpc"
  cidr    = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  azs                  = var.availability_zones
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  cluster_name    = var.cluster_name
  cluster_version = "1.24"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  self_managed_node_groups = {
    eks_nodes = {
      desired_capacity = var.node_group_size
      max_capacity     = 2
      min_capacity     = 1
      instance_type    = var.instance_type
    }
  }
}

resource "aws_kms_key" "eks" {
  description             = "EKS Cluster KMS Key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks-${random_string.suffix.result}"
  target_key_id = aws_kms_key.eks.key_id
}

data "aws_cloudwatch_log_group" "existing" {
  name = "/aws/eks/${var.cluster_name}/cluster"
}

locals {
  log_group_exists = length(data.aws_cloudwatch_log_group.existing.log_group_name) > 0
}

resource "aws_cloudwatch_log_group" "eks" {
  count             = local.log_group_exists ? 0 : 1
  name              = "/aws/eks/${var.cluster_name}/cluster-${random_string.suffix.result}"
  retention_in_days = 90
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "kms_key_id" {
  value = aws_kms_key.eks.id
}

output "log_group_name" {
  value = local.log_group_exists ? data.aws_cloudwatch_log_group.existing.name : aws_cloudwatch_log_group.eks[0].name
}