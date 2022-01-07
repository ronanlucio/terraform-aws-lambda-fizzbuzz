output "cognito_user_pool_client_id" {
  description = "ID of user pool client on cognito"
  value       = module.fizzbuzz_user_pool.cognito_user_pool_client_id
}

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.fizzbuzz.lambda_bucket_name
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = module.fizzbuzz.function_name
}

output "invoke_url" {
  description = "URL to access fizzbuzz API"
  value       = module.fizzbuzz.invoke_url
}

output "static_website_bucket_name" {
  description = "Bucket name of the static website (front-end)"
  value       = module.fizzbuzz-frontend.website_bucket_name
}
