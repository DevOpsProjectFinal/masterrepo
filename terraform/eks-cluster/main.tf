provider "aws" {
  region = var.aws_region
}

resource "random_id" "fargate_profile_id" {
  byte_length = 8
}

module "vpc" {
  source  = "./modules/vpc"
}

data "aws_iam_role" "existing_karpenter_role" {
  name = "KarpenterRole"
}

resource "aws_iam_role" "eks_fargate_pod_execution_role" {
  count = length(data.aws_iam_role.existing_karpenter_role.arn) == 0 ? 1 : 0

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
  count = length(data.aws_iam_role.existing_karpenter_role.arn) == 0 ? 1 : 0

  role       = aws_iam_role.eks_fargate_pod_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

resource "aws_iam_instance_profile" "karpenter_instance_profile" {
  count = length(data.aws_iam_role.existing_karpenter_role.arn) == 0 ? 1 : 0

  name = "KarpenterInstanceProfile"
  role = aws_iam_role.eks_fargate_pod_execution_role[0].name
}

output "karpenter_role_name" {
  value = length(data.aws_iam_role.existing_karpenter_role.arn) == 0 ? aws_iam_role.eks_fargate_pod_execution_role[0].name : data.aws_iam_role.existing_karpenter_role.name
}

# Declare KMS Key
resource "aws_kms_key" "this" {
  description = "KMS key for EKS cluster"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
POLICY
}

# Create KMS Alias
resource "aws_kms_alias" "this" {
  name          = "alias/eks/devops-project-eks-cluster"
  target_key_id = aws_kms_key.this.id  # Reference the created KMS key

  lifecycle {
    prevent_destroy = true  # Prevent destruction of the alias
  }
}
resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/eks/devops-project-eks-cluster/cluster"

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_eip" "nat" {
  count = var.create_new_resources ? 1 : 0

  domain = "vpc"
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name

  # Pass the vpc_id from the vpc module
  vpc_id = module.vpc.vpc_id
  # Pass subnets from the VPC module
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  create_eks = var.create_new_resources
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name         = module.eks.cluster_name
  fargate_profile_name = "fargate-profile-${random_id.fargate_profile_id.hex}"
  pod_execution_role_arn = length(data.aws_iam_role.existing_karpenter_role.arn) == 0 ? aws_iam_role.eks_fargate_pod_execution_role[0].arn : data.aws_iam_role.existing_karpenter_role.arn
  subnet_ids           = module.vpc.private_subnets
  
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