terraform {
  required_version = ">= 1.8.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.52.0"
    }
  }
  experiments = [module_variable_optional_attrs] # Ensure this is needed for your configuration
}