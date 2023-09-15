### Provider

# Network Account
provider "aws" {
  alias = "net"
}

# The Destination Application Account
provider "aws" {
  alias = "dst"
}

# The Destination Application Account - eu-central-1
provider "aws" {
  alias = "eu-central-1"
}

# The Destination Application Account - eu-south-1
provider "aws" {
  alias = "eu-south-1"
}


data "aws_region" "current" {
  provider = aws.dst
}


resource "random_integer" "int" {
  min = 10
  max = 100
}

module "aws_cloudfront" {
  source = "../../../aws-cloudfront"
  providers = {
    aws              = aws.dst
    aws.eu-central-1 = aws.eu-central-1 // needed for creating the Kinesis for Logging
    aws.eu-south-1   = aws.eu-south-1   // needed to update existing Bucket S3 Policy
  }
  comment                      = "tcmscloudfrontaws"
  default_root_object          = "index.html"
  enabled                      = true
  http_version                 = "http2and3"
  is_ipv6_enabled              = true
  price_class                  = "PriceClass_All"
  retain_on_delete             = true
  create_origin_access_control = true
  access_control = {
    name             = "s3_oac-${random_integer.int.result}"
    description      = "CloudFront access to S3"
    origin_type      = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
  }
  origin_distribution = {
    domain_name = var.s3_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = var.s3_bucket.s3_bucket_id
  }
  compress               = true
  viewer_protocol_policy = "allow-all"
  allowed_methods        = ["GET", "HEAD", "OPTIONS"]
  cached_methods         = ["GET", "HEAD"]
  target_origin_id       = var.s3_bucket.s3_bucket_id

  cloudfront_default_certificate = true
  ssl_support_method             = "sni-only"
  minimum_protocol_version       = "TLSv1"

  // real time logging configuration
  real_time_logging = {
    enabled       = true
    sampling_rate = 20
    fields = ["timestamp", "c-ip", "time-to-first-byte", "sc-status", "sc-bytes", "cs-method", "cs-protocol", "cs-host",
      "cs-uri-stem", "cs-bytes", "x-edge-location", "x-edge-request-id", "x-host-header", "time-taken",
      "cs-protocol-version", "c-ip-version", "cs-user-agent", "cs-referer", "cs-cookie", "cs-uri-query",
      "x-edge-response-result-type", "x-forwarded-for", "ssl-protocol", "ssl-cipher", "x-edge-result-type",
      "fle-encrypted-fields", "fle-status", "sc-content-type", "sc-content-len", "sc-range-start", "sc-range-end",
      "c-port", "x-edge-detailed-result-type", "c-country", "cs-accept-encoding", "cs-accept", "cache-behavior-path-pattern",
      "cs-headers", "cs-header-names", "cs-headers-count", "primary-distribution-id", "primary-distribution-dns-name",
    "origin-fbl", "origin-lbl", "asn"]
    destination_bucket = "arn:aws:s3:::poste-cloudfront-accesslogs-svil"
  }

}
