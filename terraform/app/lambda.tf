
# Pack the API into a zip file
data "archive_file" "lambda_fizzbuzz" {
  type = "zip"

  source_dir  = "${path.root}/lambda"
  output_path = "${path.root}/lambda.zip"
}

# Deploy lambda function
resource "aws_lambda_function" "fizzbuzz" {
  function_name = "fizzbuzz"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_fizzbuzz.key

  runtime = "nodejs14.x"
  handler = "fizzbuzz.handler"

  source_code_hash = data.archive_file.lambda_fizzbuzz.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}