### Provider

# The Destination Application Account
provider "aws" {
  alias = "dst"
}

data "aws_region" "current" {
  provider = aws.dst
}


####################################
## VPC Creation based on 
## Provided/Default CIDR
####################################

resource "aws_vpc" "app-vpc" {
  provider         = aws.dst
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "APP-VPC"
  })
}

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "internet_gateway" {
  provider = aws.dst

  # VPC in which it has to be created!
  vpc_id = aws_vpc.app-vpc.id

  tags = merge(var.tags, {
    Name = "APP-VPC-IG"
  })
}