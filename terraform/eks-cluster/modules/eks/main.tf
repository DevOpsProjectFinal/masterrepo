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
}
