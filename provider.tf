terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }

  backend "s3" {
    bucket = "daws76s-remote-state"
    key    = "provisioner"
    region = "us-east-1"
    dynamodb_table = "daws76s-locking"
  }
}

provider "aws" {
  region = "us-east-1"
}