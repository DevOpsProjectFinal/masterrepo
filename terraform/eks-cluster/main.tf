provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name = "eks-vpc"
  cidr = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  azs = var.availability_zones
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  cluster_name    = var.cluster_name
  cluster_version = "1.24"  # Update to a supported Kubernetes version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  self_managed_node_groups = {
    eks_nodes = {
      desired_capacity = var.node_group_size
      max_capacity     = 5
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

resource "aws_eks_cluster" "main" {
  name     = module.eks.cluster_name
  role_arn = module.eks.cluster_iam_role_arn

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks"
  target_key_id = aws_kms_key.eks.key_id
}