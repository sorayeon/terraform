resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "default-vpc-${var.env}"
    Temp = "Test"
  }
}

resource "aws_subnet" "public_subnet_1" {
  count             = var.env == "mydata-prd" ? 0 : 1
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "public-subnet-1-${var.env}"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "private-subnet-1-${var.env}"
  }
}
