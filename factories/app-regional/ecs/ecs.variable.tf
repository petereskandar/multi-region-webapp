variable "scope" {
  type        = string
  description = ""
}

variable "stage" {
  type        = string
  description = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = ""
}

variable "app-vpc-id" {
  type        = string
  description = "The VPC ID required for the Fargate Service Deployment"
}

variable "default-sg-id" {
  type        = string
  description = "VPC Default Security Group ID"
}

variable "public-subnets" {
  type        = list(string)
  description = "List Of VPC's Public Subnets"
}

variable "private-subnets" {
  type        = list(string)
  description = "List Of VPC's Private Subnets"
}

variable "domain_name" {
  type        = string
  description = "Public domain name needed for ACM Certificate Creation and DNS records creation"
}

variable "ecr_repository_url" {
  type        = string
  description = "The ECR Repository URL needed to Pull the Sample WebAPP Image"
}