
resource "aws_cloudwatch_log_group" "ui" {
  name              = "/ecs/aws-training-project-2-ui"
  retention_in_days = 7
}
