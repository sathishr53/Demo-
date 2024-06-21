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
    ami = "ami-08a0d1e16fc3f61ea"
    instance_type = "t2.micro"
    key_name = "dgg"
}
