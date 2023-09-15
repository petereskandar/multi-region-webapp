### Provider

# The Destination Application Account
provider "aws" {
  alias = "dst"
}

data "aws_region" "current" {
  provider = aws.dst
}

##############################
## 1 - VPC Creation Module
##############################

module "app-vpc" {
  source = "./vpc"
  providers = {
    aws.dst = aws.dst
  }
  scope = var.scope
  stage = var.stage
  tags  = var.tags
}

##############################
## 2- ECR Repo Creation
## and Sample Docket Image Push
##############################

module "app-ecr" {
  source = "./ecr"
  providers = {
    aws = aws.dst
  }
  scope = var.scope
  stage = var.stage
  tags  = var.tags
}

##############################################################
## 3- ECS Cluster & Resources
##    Creation Module (ALB, Service, Task Definition and Task)
##############################################################

module "app-ecs" {
  source = "./ecs"
  providers = {
    aws = aws.dst
  }
  scope              = var.scope
  stage              = var.stage
  tags               = var.tags
  domain_name        = var.domain_name                # Public domain name needed for ACM & Public Exposure
  ecr_repository_url = module.app-ecr.repository_url  # ECR repo url to pull the sample webapp Image
  app-vpc-id         = module.app-vpc.app-vpc-id      # VPC ID
  default-sg-id      = module.app-vpc.default-sg-id   # default SG ID
  public-subnets     = module.app-vpc.public-subnets  # Public Subnets IDs
  private-subnets    = module.app-vpc.private-subnets # Private Subnets IDs
}