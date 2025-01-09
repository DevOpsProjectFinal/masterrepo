resource "aws_eks_fargate_profile" "karpenter" {
  cluster_name = var.cluster_name
  fargate_profile_name = "${var.cluster_name}-karpenter-fargate-profile"
  pod_execution_role_arn = aws_iam_role.karpenter.arn
  subnet_ids = var.subnet_ids

  selector {
    namespace = "karpenter"
  }
}

resource "aws_iam_role" "karpenter" {
  name = "${var.cluster_name}-karpenter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
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

resource "null_resource" "helm_install_karpenter" {
  provisioner "local-exec" {
    command = <<EOT
    helm repo add karpenter https://charts.karpenter.sh
    helm repo update
    helm upgrade --install karpenter karpenter/karpenter \
      --namespace karpenter --create-namespace \
      --set controller.clusterName=${var.cluster_name} \
      --set controller.clusterEndpoint=${var.cluster_endpoint} \
      --set controller.serviceAccount.create=false \
      --set controller.serviceAccount.name=karpenter \
      --set aws.defaultInstanceProfile=${var.instance_profile_name} \
      --wait
    EOT
  }
}