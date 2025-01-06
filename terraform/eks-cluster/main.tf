  provider "aws" {
    region = var.aws_region
  }

  data "aws_availability_zones" "available" {
    # Exclude local zones
    filter {
      name   = "opt-in-status"
      values = ["opt-in-not-required"]
    }
  }

  ################################################################################
  # EKS Module
  ################################################################################

  module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.31.6"

    cluster_name    = var.cluster_name
    cluster_version = "1.31"

    # Optional
    cluster_endpoint_public_access = true

    # Optional: Adds the current caller identity as an administrator via cluster access entry
    enable_cluster_creator_admin_permissions = true

    cluster_compute_config = {
      enabled    = true
      node_pools = ["general-purpose"]
    }

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    tags = {
      Environment = "dev"
      Terraform   = "true"
    }
  }

  module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "~> 5.0"

    name = "eks-vpc"
    cidr = var.vpc_cidr

    azs             = var.availability_zones
    private_subnets = [for k, v in var.private_subnets : cidrsubnet(var.vpc_cidr, 4, k)]
    public_subnets  = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, k + 48)]
    intra_subnets   = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, k + 52)]

    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    enable_dns_support   = true

    public_subnet_tags = {
      "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
      "kubernetes.io/role/internal-elb" = 1
    }

    tags = {
      Environment = "dev"
      Terraform   = "true"
      Cluster = var.cluster_name
    }
  }

  