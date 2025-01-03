provider "aws" {
  region = var.aws_region
}

# Create a VPC (Virtual Private Cloud)
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "eks-vpc"
  cidr = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  azs = var.availability_zones
}

# Create EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  node_groups = {
    eks_nodes = {
      desired_capacity = var.node_group_size
      max_capacity     = 5
      min_capacity     = 1
      instance_type    = var.instance_type
    }
  }
}