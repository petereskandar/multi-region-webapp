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

/*module "app_secondary_region" {
  source = "./factories/regional"
  providers = {
    aws.dst = aws.secondary-region
  }
  domain_name        = local.metadata.domain_name
  domain_name_prefix = local.metadata.domain_name_prefix
  vpc_cidr_block     = local.metadata.vpc_cidr
  primary_region     = false
  tags               = local.tags
}*/



/*module "app_global" {
  source = "./factories/global"
  // NOT IN USE AT THE MOMENT
}*/
