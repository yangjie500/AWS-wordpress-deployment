terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.53.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "admin"
  region = "us-east-1"
}