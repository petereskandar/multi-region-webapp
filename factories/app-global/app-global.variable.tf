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

variable "s3_bucket" {
  type    = map(string)
  default = {}
}
