terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }
  cloud {
    hostname     = "app.terraform.io"
    organization = "sorayeon"
    workspaces {
      name = "mydata-prd"
    }
  }

}

provider "aws" {
  region = "ap-northeast-2"
}

module "default_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "default_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.100.0/24", "10.0.101.0/24"]

  /* enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true */

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
