locals {
  metadata       = yamldecode(file("metadata.yml"))
  terraform_role = "arn:aws:iam::${local.metadata.account_id}:role/AWSControlTowerExecution" #"arn:aws:iam::${local.metadata.account_id}:role/OrganizationAccountAccessRole"
  tags = {
    Environment  = local.metadata.environment
    Category     = local.metadata.category
    Project-Name = local.metadata.project_name
  }
}

// app-regional Module
// for deploying regional resources
module "app_eu_south_1" {
  source = "./factories/app-regional"
  providers = {
    aws.dst = aws.peter-master
  }
  domain_name = local.metadata.domain_name
  scope       = local.metadata.scope
  stage       = local.metadata.stage
  tags        = local.tags
}

##############################
## FAILOVER REGION
##############################

/*module "app_eu_central_1" {
  source = "./factories/app-regional"
  providers = {
    aws.dst = aws.eu-central-1
  }
  scope = local.metadata.scope
  stage = local.metadata.stage
  tags  = local.tags
}*/



/*module "app_global" {
  source = "./factories/app-global"
  providers = {
    aws.net          = aws.net
    aws.dst          = aws.us-east-1
    aws.eu-central-1 = aws.eu-central-1 // needed for creating the Kinesis for Logging
    aws.eu-south-1   = aws.eu-south-1   // needed for updating S3 Bucket Policy
  }
  scope     = local.metadata.scope
  stage     = local.metadata.stage
  tags      = local.tags
  s3_bucket = module.app_eu_south_1.s3_bucket
}*/
