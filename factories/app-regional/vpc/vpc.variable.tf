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

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}