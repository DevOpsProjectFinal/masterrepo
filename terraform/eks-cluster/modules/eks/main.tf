resource "aws_kms_key" "this" {
  description             = "KMS key for EKS"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.cluster_name}-kms-key"
  }
}
locals {
  create_node_sg = var.create_node_sg

  node_security_group_id = local.create_node_sg && length(aws_security_group.node) > 0 ? aws_security_group.node[0].id : var.node_security_group_id
}

resource "aws_security_group" "node" {
  count = local.create_node_sg ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}

resource "aws_security_group" "cluster" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-eks-cluster-sg"
  }
}

locals {
  create_cluster_sg = var.cluster_security_group_id == null
  cluster_security_group_id = local.create_cluster_sg ? aws_security_group.cluster.id : var.cluster_security_group_id
}

data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = [aws_kms_key.this.arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.aws_region}.amazonaws.com"]
    }
  }

  statement {
    actions   = ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"]
    resources = [aws_kms_key.this.arn]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

module "eks" {
  count = var.create_eks ? 1 : 0

  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  version         = "20.31.6"
  
  # Provide a valid security group ID or set create_cluster_sg to true
  cluster_security_group_id = var.cluster_security_group_id

  subnet_ids          = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }


  # Optional
  cluster_endpoint_public_access = true

  # Disable KMS
  kms_key_enable_default_policy = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true


  fargate_profiles = var.fargate_profiles
}
