# Create a random name to be used on bucket
resource "random_pet" "cognito_domain" {
  prefix = "fizzbuzz-lambda"
  length = 4
}

# Create cognito user pool
resource "aws_cognito_user_pool" "pool" {
  name = "${var.api_name}_pool"

  alias_attributes           = ["email"]
  auto_verified_attributes   = ["email"]

  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  username_configuration {
    case_sensitive = false
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true

    string_attribute_constraints {
      min_length = 7
      max_length = 256
    }
  }

  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true

    string_attribute_constraints {
      min_length = 3
      max_length = 256
    }
  }
}

# Create a cognito user pool client
resource "aws_cognito_user_pool_client" "client" {
  name                = "${var.api_name}_client"

  supported_identity_providers         = ["COGNITO"]
  
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH", 
    "ALLOW_REFRESH_TOKEN_AUTH", 
    "ALLOW_USER_SRP_AUTH"
  ]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "aws.cognito.signin.user.admin", "profile", "openid"]
  callback_urls                        = ["${var.cognito_callback_url}"]
  logout_urls                          = ["${var.cognito_logout_url}"]

  user_pool_id        = aws_cognito_user_pool.pool.id
}

# Creates amazon cognito domain
resource "aws_cognito_user_pool_domain" "fizzbuzz" {
  domain       = random_pet.cognito_domain.id
  user_pool_id = aws_cognito_user_pool.pool.id
}
