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

// Login to ECR Repo
// Build the sample WebApp
// tag and push to the repo
resource "null_resource" "docker_packaging" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<EOF
        aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com 
        docker build --build-arg REGION=${data.aws_region.current.name} -t web-app-repo ${path.module}/webapp 
        docker tag web-app-repo:latest ${module.ecr.repository_url}:latest 
	      docker push ${module.ecr.repository_url}:latest
	    EOF
  }

  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    module.ecr
  ]
}

