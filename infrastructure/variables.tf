
variable "aws_region" {
  description = "AWS region for the project"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name used for AWS resources"
  type        = string
  default     = "aws-training-project-2"
}