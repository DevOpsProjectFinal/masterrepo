provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "./modules/vpc"
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  
  # Define Fargate profiles
  fargate_profiles = {
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

data "template_file" "karpenter_trust_policy" {
  template = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "karpenter.k8s.aws"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOT
}

data "template_file" "karpenter_policy" {
  template = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:Describe*",
          "ec2:TerminateInstances",
          "ec2:DeleteTags"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "iam:PassRole"
        ],
        "Resource": "arn:aws:iam::*:role/*"
      }
    ]
  }
  EOT
}

resource "aws_iam_role" "karpenter" {
  name = "KarpenterController"
  assume_role_policy = data.template_file.karpenter_trust_policy.rendered
}

resource "aws_iam_policy" "karpenter_controller" {
  name   = "KarpenterControllerPolicy"
  policy = data.template_file.karpenter_policy.rendered
}

resource "aws_iam_role_policy_attachment" "karpenter_attach" {
  role       = aws_iam_role.karpenter.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.30.0"

  values = [
    yamlencode({
      "serviceAccount.create" = false
      "serviceAccount.name"   = "karpenter"
      "clusterName"           = var.cluster_name
      "clusterEndpoint"       = module.eks.cluster_endpoint
    })
  ]
}