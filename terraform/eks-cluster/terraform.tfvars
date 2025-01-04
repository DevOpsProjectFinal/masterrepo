# terraform.tfvars

aws_region      = "us-west-2"
vpc_cidr        = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
cluster_name    = "my-first-eks-cluster"
node_group_size = 2
instance_type   = "t3.medium"
vpc_id = vpc-0962ee4b2b3a1533e
subnets = ["subnet-00bf1c3a780dc5312", "subnet-0389e51db9d208993", "subnet-0e6a643c74384fa42", "subnet-05cf4f65fff952285", "subnet-0aee2b43e88a30951", "subnet-0c0758a2820d6aafc"]
