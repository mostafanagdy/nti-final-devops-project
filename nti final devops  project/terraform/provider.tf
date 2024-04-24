provider "aws" {
  region = "us-east-1"
  profile= "default"
  access_key = "AKIAXYKJWGOGAVZHDPVJ"
  secret_key = "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"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}