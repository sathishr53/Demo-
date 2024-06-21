terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-04b70fa74e45c3917"
    instance_type = "t2.micro"
    key_name = "ghk"
    //security_groups = ["demo-sg"]
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.ghk-public-subnet-01.id
    for_each = toset(["jenkins-master", "build-slave","ansible"])
   tags = {
     Name = "${each.key}"
   }

}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "ssh access"
  vpc_id = aws_vpc.ghk-vpc.id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "ghk-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    name = "ghk-vpc"
  }
  
}

resource "aws_subnet" "ghk-public-subnet-01" {
  vpc_id = aws_vpc.ghk-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    name = "ghk-public-subnet-01"
  }
  
}

resource "aws_subnet" "ghk-public-subnet-02" {
  vpc_id = aws_vpc.ghk-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    name = "ghk-public-subnet-02"
  }
  
}

resource "aws_internet_gateway" "ghk-igw" {
  vpc_id = aws_vpc.ghk-vpc.id
  tags = {
    name = "ghk-igw"
  }
}

resource "aws_route_table" "ghk-public-rt" {
  vpc_id = aws_vpc.ghk-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ghk-igw.id
  }
}

resource "aws_route_table_association" "ghk-rta-public-subnet-01" {
  subnet_id = aws_subnet.ghk-public-subnet-01.id
  route_table_id = aws_route_table.ghk-public-rt.id

}

resource "aws_route_table_association" "ghk-rta-public-subnet-02" {
  subnet_id = aws_subnet.ghk-public-subnet-02.id
  route_table_id = aws_route_table.ghk-public-rt.id

}