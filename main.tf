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

  name = "default-vpc-${terraform.workspace}"
  cidr = "10.0.0.0/16"

  azs = ["ap-northeast-2a", "ap-northeast-2c"]
  /*private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]*/
  public_subnets = ["10.0.100.0/24", "10.0.101.0/24"]

  manage_default_security_group = true
  /* enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true */

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_instance" "web_instances" {
  count         = 2
  ami           = "ami-013218fccb68a90d4"
  instance_type = "t2.micro"
  subnet_id     = module.default_vpc.public_subnets[count.index]

  tags = {
    Name = "web-instance-${count.index}"
  }
}

module "web_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "web-alb"

  load_balancer_type = "application"

  vpc_id          = module.default_vpc.vpc_id
  subnets         = module.default_vpc.public_subnets
  security_groups = [module.default_vpc.default_security_group_id]

  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

}
