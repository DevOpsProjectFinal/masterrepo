module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  version         = "20.31.6"
  
  subnet_ids          = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # Optional
  cluster_endpoint_public_access = true

  # Disable KMS
  kms_key_enable_default_policy = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # IRSA for AWS Load Balancer Controller
  enable_irsa = true

  #eks_managed_node_groups = {
  #  devops_project_eks_ng = {
  #    # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
  #    ami_type       = "AL2_x86_64"
  #    instance_types = ["t3.micro"]

  #    min_size = 3
  #    max_size = 10
  #    # This value is ignored after the initial creation
  #    # https://github.com/bryantbiggs/eks-desired-size-hack
  #    desired_size = 3
  #    disk_size        = 10  # Specify the root volume size in GB (minimum is 10 GB)
  #  }
  #}
}
