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

module "main_vpc" {
  source = "./custom_vpc"
  env    = terraform.workspace
}
