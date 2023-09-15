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

variable "domain_name" {
  type        = string
  description = "Public domain name needed for ACM Certificate Creation and DNS records creation"
}