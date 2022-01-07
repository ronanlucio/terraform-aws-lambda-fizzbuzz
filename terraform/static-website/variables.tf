variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "api_name" {
  description = "API name"
  type        = string
}

variable "site_domain" {
  description = "Website domain for hosting static website"
  type        = string
}

variable "site_folder" {
  description = "Local folder (relative to project's root) containing website files"
  type        = string
}

variable "cognito_callback_url" {
  description = "Callback URL to be set on Cognito"
  type        = string
}
