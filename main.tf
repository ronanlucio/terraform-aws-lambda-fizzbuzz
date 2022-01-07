terraform {
  backend "s3" {
    bucket = "${var.api_name}-backend-terraform"
    region = var.aws_region
    dynamodb_table = "${var.api_name}-terraform-locks"
    key = "${var.api_name}/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

# Set AWS provider
provider "aws" {
  region = var.aws_region
}

# Create cognito user pool
module "fizzbuzz_user_pool" {
  source = "./terraform/cognito"

  api_name             = "fizzbuzz"
  cognito_callback_url = var.cognito_callback_url
  cognito_logout_url   = var.cognito_logout_url
}

# Enable api logging
module "fizzbuzz_logs" {
  source = "./terraform/app-logs"

  depends_on = [module.fizzbuzz_user_pool]
}

# Create lambda function and rest api
module "fizzbuzz" {
  source = "./terraform/app"

  api_name              = "fizzbuzz"
  aws_region            = var.aws_region
  cognito_user_pool_arn = module.fizzbuzz_user_pool.cognito_user_pool_arn

  depends_on = [module.fizzbuzz_logs]
}

# Host front-end webpate
module "fizzbuzz-frontend" {
  source = "./terraform/static-website"

  aws_region           = var.aws_region
  api_name             = var.api_name
  site_domain          = var.site_domain
  site_folder          = var.site_folder
  cognito_callback_url = var.cognito_callback_url

  depends_on = [module.fizzbuzz]
}