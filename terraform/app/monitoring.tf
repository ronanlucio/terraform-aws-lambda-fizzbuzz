# Set logs retention period
resource "aws_cloudwatch_log_group" "fizzbuzz" {
  name = "/aws/lambda/${aws_lambda_function.fizzbuzz.function_name}"

  retention_in_days = 7
}