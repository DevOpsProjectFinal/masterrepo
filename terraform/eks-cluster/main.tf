provider "aws" {
  region = var.aws_region
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "arn:aws:kms:region:account-id:key/key-id"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        for principal in var.principals : principal if principal != null
      ]
    }
  }
}

resource "aws_security_group" "cluster" {
  count = var.create_cluster_security_group ? 1 : 0

  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS Cluster security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

resource "aws_security_group" "node" {
  count = var.create_node_security_group ? 1 : 0

  name        = "${var.cluster_name}-node-sg"
  description = "EKS Node security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
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
  cluster_version = "1.31"
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

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster-${random_string.suffix.result}"
  retention_in_days = 90
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.eks.id
}

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.eks.name
}

