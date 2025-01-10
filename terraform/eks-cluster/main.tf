provider "aws" {
  region = var.aws_region
}

resource "random_id" "fargate_profile_id" {
  byte_length = 8
}
