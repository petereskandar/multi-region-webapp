####################################
## ACM Certificate Creation
####################################

data "aws_route53_zone" "public-zone" {
  name = var.domain_name
}

module "wildcard_cert" {
  source = "terraform-aws-modules/acm/aws"

  domain_name = "*.${var.domain_name}"
  zone_id     = data.aws_route53_zone.public-zone.id
}

####################################
## ALB Creation for Public Exposure
####################################

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "APP-PUBLIC-ALB"
  load_balancer_type = "application"
  security_groups    = [var.default-sg-id]
  subnets            = var.public-subnets
  vpc_id             = var.app-vpc-id

  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      description = "Permit incoming HTTP requests from the internet"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_all_https = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      description = "Permit incoming HTTPs requests from the internet"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Permit all outgoing requests to the internet"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  http_tcp_listeners = [
    {
      # * Setup a listener on port 80 and forward all HTTP
      # * traffic to target_groups[0] defined below which
      # * will eventually point to our "Hello World" app.
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.wildcard_cert.acm_certificate_arn
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      backend_port     = 80
      backend_protocol = "HTTP"
      target_type      = "ip"
    }
  ]
}

####################################
## DNS Record Creation for the ALB
## Route53 Health Checks
####################################

// route53 health check
resource "aws_route53_health_check" "failover_healt_check" {
  fqdn              = module.alb.lb_dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  request_interval  = 30
  failure_threshold = 3
  tags = merge(var.tags, {
    Name = "${var.domain_name_prefix}.${data.aws_region.current.name}-health-check"
  })
}

resource "aws_route53_record" "dns_record" {
  zone_id = data.aws_route53_zone.public-zone.zone_id
  name    = lower("${var.domain_name_prefix}.${var.domain_name}")
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }

  set_identifier = var.primary_region ? "primary" : "secondary"
  failover_routing_policy {
    type = var.primary_region ? "PRIMARY" : "SECONDARY"
  }

  health_check_id = aws_route53_health_check.failover_healt_check.id

}
