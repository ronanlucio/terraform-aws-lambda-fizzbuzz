variable "api_name" {
  description = "API name"
  type        = string
  default     = "fizzbuzz"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cognito_user_pool_arn" {
  description = "arn of user pool created on cognito"
  type        = string
}