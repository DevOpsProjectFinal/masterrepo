provider "aws" {
  region = var.aws_region
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

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

output "kubeconfig" {
  sensitive = true
  value = <<-EOT
    apiVersion: v1
    clusters:
    - cluster:
        server: ${module.eks.cluster_endpoint}
        certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
      name: ${module.eks.cluster_name}
    contexts:
    - context:
        cluster: ${module.eks.cluster_name}
        user: ${module.eks.cluster_name}
      name: ${module.eks.cluster_name}
    current-context: ${module.eks.cluster_name}
    kind: Config
    users:
    - name: ${module.eks.cluster_name}
      user:
        token: ${data.aws_eks_cluster_auth.eks.token}
  EOT
}

resource "aws_iam_role" "karpenter" {
  name = "KarpenterController"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "karpenter.k8s.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.karpenter.name
}

resource "aws_iam_role_policy_attachment" "karpenter_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.karpenter.name
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.16.3"

  values = [
    yamlencode({
      "serviceAccount.create" = false,
      "serviceAccount.name"   = "karpenter",
      "clusterName"           = var.cluster_name,
      "clusterEndpoint"       = module.eks.cluster_endpoint
    })
  ]
}