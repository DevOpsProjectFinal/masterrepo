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

resource "aws_iam_role" "lb_controller_role" {
  name = "lb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lb_controller_policy_attachment" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_certificate_authority_data
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  version    = "2.4.1"  # Ensure you use the latest stable version

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks.amazonaws.com/role-arn"
    value = aws_iam_role.lb_controller_role.arn
  }
}
