resource "aws_vpc" "32bits-vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  instance_tenancy     = "default"

  tags = {
    "Name" = "32bits-vpc"
  }
}

resource "aws_subnet" "32bits-subnet-public-1" {
  vpc_id                  = aws_vpc.32bits-vpc.id
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    "Name" = "32bits-subnet-public-1"
  }
}

resource "aws_subnet" "32bits-subnet-public-2" {
  vpc_id                  = aws_vpc.32bits-vpc.id
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"

  tags = {
    "Name" = "32bits-subnet-public-2"
  }
}

resource "aws_subnet" "32bits-subnet-public-3" {
  vpc_id                  = aws_vpc.32bits-vpc.id
  cidr_block              = "172.31.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1c"

  tags = {
    "Name" = "32bits-subnet-public-3"
  }
}

resource "aws_internet_gateway" "32bits-igw" {
  vpc_id = aws_vpc.32bits-vpc.id

  tags = {
    "Name" = "32bits-igw"
  }
}

resource "aws_route_table" "32bits-public-crt" {
  vpc_id = aws_vpc.32bits-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.32bits-igw.id
  }

  tags = {
    Name = "32bits-public-crt"
  }
}

resource "aws_route_table_association" "32bits-crta-public-subnet-1" {
  subnet_id      = aws_subnet.32bits-subnet-public-1.id
  route_table_id = aws_route_table.32bits-public-crt.id
}

resource "aws_route_table_association" "32bits-crta-public-subnet-2" {
  subnet_id      = aws_subnet.32bits-subnet-public-2.id
  route_table_id = aws_route_table.32bits-public-crt.id
}

resource "aws_route_table_association" "32bits-crta-public-subnet-3" {
  subnet_id      = aws_subnet.32bits-subnet-public-3.id
  route_table_id = aws_route_table.32bits-public-crt.id
}

resource "aws_security_group" "32bits-all" {
  vpc_id = aws_vpc.32bits-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "32bits-all"
  }
}
