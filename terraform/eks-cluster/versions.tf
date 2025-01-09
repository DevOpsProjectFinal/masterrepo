terraform {
  required_version = ">= 1.8.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.81"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }
  }
}