terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

// Dont think this is needed as we're using SSM
//resource "aws_key_pair" "spinnaker" {
//  key_name   = "spinnaker-key"
//  public_key = file("~/.ssh/aws-keys/spinnaker-key.pub")
//}

module "spinnaker_iam_resources" {
  source = "./modules/spinnaker/iam/"
}
