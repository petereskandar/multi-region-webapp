######################################
## MY Current AWS Account
######################################

// my account
provider "aws" {
  alias      = "primary-region"
  region     = "eu-south-1"
}

provider "aws" {
  alias      = "secondary-region"
  region     = "eu-central-1"
}
