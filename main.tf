terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.22.0"
    }
  }
  required_version = "~> 0.14"
}

provider "aws" {
  region = var.region
}

resource "random_uuid" "randomid" {}

resource "aws_iam_user" "circleci" {
  name = var.user
  path = "/system/"
}

resource "aws_iam_access_key" "circleci" {
  user = aws_iam_user.circleci.name
}

data "template_file" "circleci_policy" {
  template = file("circleci_s3_access.tpl.json")
  vars = {
    s3_bucket_arn = aws_s3_bucket.app.arn
  }
}

resource "local_file" "circle_credentials" {
  filename = "tmp/circleci_credentials"
  content  = "${aws_iam_access_key.circleci.id}\n${aws_iam_access_key.circleci.secret}"
}

resource "aws_iam_user_policy" "circleci" {
  name   = "AllowCircleCI"
  user   = aws_iam_user.circleci.name
  policy = data.template_file.circleci_policy.rendered
}

resource "aws_s3_bucket" "app" {
  tags = {
    Name = "App Bucket"
  }

  bucket = "${var.app}.${var.label}.${random_uuid.randomid.result}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  force_destroy = true

}

resource "aws_s3_bucket_object" "app" {
  acl          = "public-read"
  key          = "index.html"
  bucket       = aws_s3_bucket.app.id
  content      = file("./assets/index.html")
  content_type = "text/html"

}

output "Endpoint" {
  value = aws_s3_bucket.app.website_endpoint
}

#terraform {
  #backend "s3" {
   # bucket = "ce5e6e58-2cff-3a82-3bc4-62d166b0946e-backend"
    #key    = "terraform/webapp/terraform.tfstate"
    #region = "eu-central-1"
  #}
#}

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


resource "aws_instance" "linux-instance" {
  ami           = "ami-0767046d1677be5a0"  #Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"

  subnet_id = aws_subnet.32bits-subnet-public-3.id

  vpc_security_group_ids = [aws_security_group.32bits-all.id]

  key_name = "itea"

  tags = {
    "Name" = "linux-instance"
  }

  depends_on = [
    aws_db_instance.32bits-rds,
  ]
}


