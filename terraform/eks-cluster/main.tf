provider "aws" {
  region = var.aws_region
}

resource "random_id" "fargate_profile_id" {
  byte_length = 8
}

module "vpc" {
  source  = "./modules/vpc"
}

resource "aws_iam_role" "eks_fargate_pod_execution_role" {
  name = "KarpenterRole"

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

  lifecycle {
    ignore_changes = [name]  # Ignore changes to the "name" attribute
  }
}

resource "aws_iam_policy" "karpenter_policy" {
  name        = "KarpenterPolicy"
  description = "Policy for Karpenter to manage EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeImages",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        Resource = "*"
      }
    ]
  })

  lifecycle {
    ignore_changes = [name]  # Ignore changes to the "name" attribute
  }
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_attachment" {
  role       = aws_iam_role.eks_fargate_pod_execution_role.name
  policy_arn = aws_iam_policy.karpenter_policy.arn
}

resource "aws_iam_instance_profile" "karpenter_instance_profile" {
  name = "KarpenterInstanceProfile"
  role = aws_iam_role.eks_fargate_pod_execution_role.name
}

resource "aws_kms_alias" "this" {
  name          = "alias/eks/devops-project-eks-cluster"
  target_key_id = aws_kms_key.this.id

  lifecycle {
    # Ignore the creation of the alias if it already exists.
    prevent_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/eks/devops-project-eks-cluster/cluster"

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_eip" "nat" {
  count = length(module.eks.cluster_name) > 0 ? 0 : 1
  vpc   = true
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
  fargate_profile_name = "fargate-profile-${random_id.fargate_profile_id.hex}"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids               = module.vpc.private_subnets
  
  selector {
    namespace = "default"
  }

  selector {
    namespace = "kube-system"
  }

  selector {
    namespace = "karpenter"
  }

  depends_on = [module.eks]
}