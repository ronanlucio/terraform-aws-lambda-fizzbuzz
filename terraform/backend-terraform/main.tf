provider "aws" {
  region = "${var.aws_region}"
}

# Create S3 bucket to store terraform state
resource "aws_s3_bucket" "backend_terraform" {
  bucket        = "${var.api_name}-backend-terraform"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }
}

# Create DynamoDB table for terraform lock state
resource "aws_dynamodb_table" "dynamodb-table" {
  name           = "${var.api_name}-terraform-locks"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}