# Create a random name to be used on bucket
resource "random_pet" "lambda_bucket_name" {
  prefix = "fizzbuzz-lambda"
  length = 4
}

# Create a S3 bucket to upload source code
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  acl           = "private"
  force_destroy = true
}

# Upload api package to S3 bucket
resource "aws_s3_bucket_object" "lambda_fizzbuzz" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "lambda.zip"
  source = data.archive_file.lambda_fizzbuzz.output_path

  etag = filemd5(data.archive_file.lambda_fizzbuzz.output_path)
}