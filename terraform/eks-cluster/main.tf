provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "./modules/vpc"
  name    = var.name
  cidr    = var.cidr
  azs     = var.availability_zones
  public_subnets  = var.private_subnets
  private_subnets = var.public_subnets
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  cluster_version     = "1.31"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets
  private_subnets     = module.vpc.private_subnets

  # Disable Managed Node Groups
  enable_managed_node_groups = false

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

resource "aws_iam_role" "karpenter" {
  name = "KarpenterController"
  assume_role_policy = file("./karpenter-trust-policy.json")
}

resource "aws_iam_policy" "karpenter_controller" {
  name   = "KarpenterControllerPolicy"
  policy = file("./karpenter-policy.json")
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
    {
      "serviceAccount.create" = false
      "serviceAccount.name"   = "karpenter"
      "clusterName"           = module.eks.cluster_name
      "clusterEndpoint"       = module.eks.cluster_endpoint
    }
  ]
}
