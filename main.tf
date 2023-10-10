locals {
  metadata = yamldecode(file("metadata.yml"))
  #terraform_role = "arn:aws:iam::${local.metadata.account_id}:role/OrganizationAccountAccessRole"
  tags = {
    Environment  = local.metadata.environment
    Category     = local.metadata.category
    Project-Name = local.metadata.project_name
  }
}


##############################
## PRIMARY REGION
##############################

// app-regional Module
// for deploying regional resources
module "app_primary_region" {
  source = "./factories/regional"
  providers = {
    aws.dst = aws.primary-region
  }
  domain_name        = local.metadata.domain_name
  domain_name_prefix = local.metadata.domain_name_prefix
  vpc_cidr_block     = local.metadata.vpc_cidr
  primary_region     = true
  tags               = local.tags
}

##############################
## FAILOVER REGION
##############################

module "app_secondary_region" {
  source = "./factories/regional"
  providers = {
    aws.dst = aws.secondary-region
  }
  domain_name        = local.metadata.domain_name
  domain_name_prefix = local.metadata.domain_name_prefix
  vpc_cidr_block     = local.metadata.vpc_cidr
  primary_region     = false
  tags               = local.tags
}




##############################
## Demo EC2 Instance
##############################

resource "aws_instance" "example" {
  provider = aws.primary-region
  ami           = "ami-04add7ad5deef1ffd"
  instance_type = "t3.large"
  subnet_id     = "subnet-089218a7c1feb905a"

  tags = {
    Name = "ec2-example"
  }
}