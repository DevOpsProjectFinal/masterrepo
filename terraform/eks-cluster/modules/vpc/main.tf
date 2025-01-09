module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  cidr            = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = [var.private_subnets[0]]
  public_subnets  = var.public_subnets
  enable_nat_gateway = true
  enable_dns_hostnames = true
  
  # Optional, if you want to assign a name to the VPC (this is supported in the module)
  name = var.vpc_name
}
