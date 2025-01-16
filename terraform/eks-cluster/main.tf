provider "aws" {
  region = var.aws_region
}

resource "random_id" "fargate_profile_id" {
  byte_length = 8
}

module "vpc" {
  source  = "./modules/vpc"
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name

  # Pass the vpc_id from the vpc module
  vpc_id = module.vpc.vpc_id
  # Pass subnets from the VPC module
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name         = module.eks.cluster_name
  fargate_profile_name = "fargate-profile"

  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "default"

    # Optionally add labels to match specific pods
    labels = {
      environment = "dev"
    }
  }

  selector {
    namespace = "kube-system"
  }

  selector {
    namespace = "fargate-applications"
  }

}

resource "aws_iam_role" "eks_fargate_pod_execution_role" {
  name = "eks-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
  ])

  policy_arn = each.value
  role      = aws_iam_role.eks_fargate_pod_execution_role.name
}