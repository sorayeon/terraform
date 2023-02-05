terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }
  backend "s3" {
    bucket = "mydata-tf-backend-bucket"
    key    = "terraform.tfstate"
    region = "ap-northeast-2"
    //workspace_key_prefix = "env" // env:
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

/* 개발 */
/* module "dev_custom_vpc" {
  source = "./custom_vpc"
  env    = "dev"
} */

/* 운영 */
/* module "prd_custom_vpc" {
  source = "./custom_vpc"
  env    = "prd"
} */

/* variable "envs" {
  type    = list(string)
  default = ["dev", "prd", ""]

} */

/* count */
/* module "personal_custom_vpc" {
  count  = 2
  source = "./custom_vpc"
  env    = "personal_${count.index}"
} */

/* for_each */
/* module "vpc_list" {
  //for_each = toset(var.names)
  for_each = toset([for env in var.envs : env if env != ""])
  source   = "./custom_vpc"
  env      = each.key
} */

module "main_vpc" {
  source = "./custom_vpc"
  env    = terraform.workspace
}

resource "aws_s3_bucket" "tf_backend" {
  count  = terraform.workspace == "default" ? 1 : 0
  bucket = "mydata-tf-backend-bucket"

  tags = {
    Name = "mydata-tf_backend"
  }
}

resource "aws_s3_bucket_acl" "tf_backend_acl" {
  count  = terraform.workspace == "default" ? 1 : 0
  bucket = aws_s3_bucket.tf_backend[0].id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_backend_versioning" {
  count  = terraform.workspace == "default" ? 1 : 0
  bucket = aws_s3_bucket.tf_backend[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

/* 
resource "aws_eip" "temp_eip" {
  provisioner "local-exec" {
    command = "echo ${self.public_ip}" //
  }

  tags = {
    Name = "temp_eip"
  }
} */
