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

module "web_elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 2.0"

  name            = "web-elb-http"
  subnets         = module.default_vpc.public_subnets
  security_groups = [module.default_vpc.default_security_group_id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    }
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  number_of_instances = 2
  instances           = aws_instance.web_instances[*].id

}
