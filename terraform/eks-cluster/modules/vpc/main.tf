module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version         = "5.17.0"
  cidr            = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_nat_gateway = true
  enable_dns_hostnames = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  # Optional, if you want to assign a name to the VPC (this is supported in the module)
  name = var.vpc_name

  tags = {
    "Name"                                      = "terraform-eks-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
