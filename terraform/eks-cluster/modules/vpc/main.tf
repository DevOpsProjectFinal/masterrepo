module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = var.name
  cidr    = var.cidr
  azs     = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}
