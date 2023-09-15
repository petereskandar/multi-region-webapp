variable "tags" {
  type        = map(string)
  default     = {}
  description = ""
}

variable "vpc_cidr_block" {
  type = string
}