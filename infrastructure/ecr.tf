
resource "aws_ecr_repository" "ui" {
  name                 = "aws-training-project-2-ui"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ui.repository_url
}
