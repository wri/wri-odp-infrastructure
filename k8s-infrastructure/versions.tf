provider "aws" {
  region = var.aws_region
  profile = "wri-aws-terraform"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.21"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
  required_version = "~> 1.5"
}
