# terraform.tfvars

aws_region      = "us-west-2"
vpc_cidr        = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
cluster_name    = "my-first-eks-cluster"
node_group_size = 2
instance_type   = "t3.medium"
