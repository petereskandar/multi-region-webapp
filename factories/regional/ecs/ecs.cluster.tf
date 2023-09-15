####################################
## ECS Cluster Creation
## Task Definition, Task and Service
####################################

module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "APP-ECS-FARGATE"
  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  task_exec_iam_role_name = "webapp-task-role"

  services = {
    // WebAPP Service Definition
    webApp-frontend = {
      cpu    = 1024
      memory = 4096

      # Container definition
      container_definitions = {

        nginx-server = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/web-app-repo:latest" # Sample WebAPP Image from the Private ECR Repo
          port_mappings = [
            {
              name          = "nginx-server"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          readonly_root_filesystem  = false
          enable_cloudwatch_logging = false
          memory_reservation        = 100
        }
      }

      load_balancer = {
        service = {
          target_group_arn = element(module.alb.target_group_arns, 0)
          container_name   = "nginx-server"
          container_port   = 80
        }
      }
      // scheduled autoscaling
      autoscaling_scheduled_actions = {
        scheduled-scale-out = {
          name         = "scheduled-scale-out"
          min_capacity = 5
          max_capacity = 10
          schedule     = "cron(16 21 * * ? *)"
        }
        scheduled-scale-in = {
          name         = "scheduled-scale-in"
          min_capacity = 1
          max_capacity = 5
          schedule     = "cron(20 21 * * ? *)"
        }
      }

      subnet_ids = var.private-subnets
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = var.tags
}

