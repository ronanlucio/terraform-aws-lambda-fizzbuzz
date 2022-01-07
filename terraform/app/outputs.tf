output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {
  description = "Name of the Lambda function."
  value = aws_lambda_function.fizzbuzz.function_name
}

output "invoke_url" {
  description = "URL to access fizzbuzz API"
  value = aws_api_gateway_stage.dev.invoke_url
}