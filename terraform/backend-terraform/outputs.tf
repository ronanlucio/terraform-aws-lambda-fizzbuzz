output "bucket_name" {
  description = "Bucket name for terraform state"
  value       = aws_s3_bucket.backend_terraform.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table for terraform lock state"
  value       = aws_dynamodb_table.dynamodb-table.id
}