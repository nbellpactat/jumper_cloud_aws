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

module "ssm_resources" {
  source = "./modules/ssm-baseline"
}

module "spinnaker_iam_resources" {
  source = "./modules/spinnaker/iam/"
}

module "spinnaker_vpc_resources" {
  source                             = "./modules/spinnaker/vpc"
  nat_gateway_name                   = "NAT Test"
  spinnaker_private_route_table_name = "Test RT"
  spinnaker_private_subnet_name      = "Test pvt subnet"
  spinnaker_public_subnet_name       = "Test pub subnet"
  spinnaker_subnet_private_cidr      = "10.15.1.0/28"
  spinnaker_subnet_public_cidr       = "10.15.2.0/28"
  spinnaker_vpc_cidr                 = "10.15.0.0/20"
  spinnaker_vpc_name                 = "spinnaker_vpc"
  internet_gateway_name              = "spinnaker_igw"
  nat_eip_name                       = "spinnaker_nat_eip"
}

module "spinnaker_ec2_resources" {
  depends_on = [module.spinnaker_vpc_resources, module.ssm_resources]

  source           = "./modules/spinnaker/ec2"
  spinnaker_vpc_id = module.spinnaker_vpc_resources.spinnaker_vpc_id
  subnet_id        = module.spinnaker_vpc_resources.spinnaker_private_subnet_id
  spinnaker_security_group_id = module.spinnaker_vpc_resources.spinnaker_security_group_id
}