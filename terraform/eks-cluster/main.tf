provider "aws" {
  region = var.aws_region
}

resource "random_id" "fargate_profile_id" {
  byte_length = 8
}

module "vpc" {
  source  = "./modules/vpc"
  cluster_name = var.cluster_name
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

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name         = module.eks.cluster_name
  fargate_profile_name = "fargate-profile"

  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "default"
  }

  selector {
    namespace = "kube-system"
  }

  selector {
    namespace = "fargate-applications"
    labels = {
      "tier": "frontend"
    }
  }

  selector {
    namespace = "fargate-applications"
    labels = {
      "tier": "backend"
    }
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
      },
      {
        "Effect": "Allow",
        "Principal": {
            "Federated": module.eks.oidc_provider_arn
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
            "StringEquals": {
                "${module.eks.eks_oidc_id}::aud": "sts.amazonaws.com",
                "${module.eks.eks_oidc_id}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
            }
        }
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

resource "aws_iam_role" "load_balancer_controller" {
  name = "eks-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        "Effect": "Allow",
        "Principal": {
            "Federated": module.eks.oidc_provider_arn
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
            "StringEquals": {
                "${module.eks.eks_oidc_id}::aud": "sts.amazonaws.com",
                "${module.eks.eks_oidc_id}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
            }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "load_balancer_controller_policy" {
  name = "load-balancer-controller-policy"

  policy = file("${path.module}/iam_policy.json") # Replace with your policy file path
}

resource "aws_iam_role_policy_attachment" "attach_lb_controller_policy" {
  policy_arn = aws_iam_policy.load_balancer_controller_policy.arn
  role       = aws_iam_role.load_balancer_controller.name
}



locals {
  kube_system_namespace = "kube-system"
  alb_service_account_name = "alb-controller"
  efs_service_account_name = "efs-controller"
  system_service_accounts = [
    "${local.kube_system_namespace}:${local.alb_service_account_name}"
  ]
}

resource "kubernetes_service_account" "alb" {
  metadata {
    name = local.alb_service_account_name
    namespace = local.kube_system_namespace
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.vpc_cni_irsa.iam_role_arn
    }
  }
}

module "vpc_cni_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name_prefix      = "vpc-cni-irsa-"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = local.system_service_accounts
    }
  }

}