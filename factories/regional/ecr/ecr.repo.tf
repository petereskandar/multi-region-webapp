########################################
## ECR REPO CREATION
########################################

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name                 = "web-app-repo"
  create_lifecycle_policy         = true
  repository_image_tag_mutability = "MUTABLE"
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  tags = var.tags
}

# Equivalent of aws ecr get-login
data "aws_ecr_authorization_token" "ecr_token" {}

// Login to ECR Repo
// Build the sample WebApp
// tag and push to the repo
resource "null_resource" "docker_packaging" {
  # aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com 
  # echo ${data.aws_ecr_authorization_token.ecr_token.password} | docker login —username ${data.aws_ecr_authorization_token.ecr_token.user_name} —password-stdin ${data.aws_ecr_authorization_token.ecr_token.proxy_endpoint}
  # docker login --username AWS -p $(aws ecr get-login-password --region ${data.aws_region.current.name} ) ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<EOF
        docker login --username AWS -p $(aws ecr get-login-password --region ${data.aws_region.current.name} ) ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com      
        docker build --build-arg REGION=${data.aws_region.current.name} -t web-app-repo-${data.aws_region.current.name} ${path.module}/webapp 
        docker tag web-app-repo-${data.aws_region.current.name}:latest ${module.ecr.repository_url}:latest 
	      docker push ${module.ecr.repository_url}:latest
	    EOF
  }

  triggers = {
    token_expired = data.aws_ecr_authorization_token.ecr_token.expires_at
  }

  depends_on = [
    module.ecr
  ]
}