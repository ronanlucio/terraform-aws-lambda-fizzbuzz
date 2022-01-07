variable "api_name" {
  description = "API name"
  type = string
  default = "fizzbuzz"
}

variable "cognito_callback_url" {
  description = "Callback URL to be set on Cognito"
  type        = string
}

variable "cognito_logout_url" {
  description = "Logout URL to be set on Cognito"
  type        = string
}