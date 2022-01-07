# Create an S3 bucket to host the static website
resource "aws_s3_bucket" "site" {
  bucket = "${var.api_name}.${var.site_domain}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# Create a bucket policy to make the website public accessible
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*",
        ]
      },
    ]
  })
}

# Set cognito callback url with variable value
resource "null_resource" "set_callback_index_html" {
    triggers = {
        etag = filemd5("${path.root}/${var.site_folder}/index.html")
    }

    provisioner "local-exec" {
        # NOTE: We're not using "/" for sed to avoid conflicting with https://
        command     = "sed -e \"s~COGNITO_CALLBACK_URL~$CALLBACK_URL~g\" index.html.template > index.html"
        working_dir = "${path.root}/${var.site_folder}"

        environment = {
            CALLBACK_URL = "${var.cognito_callback_url}"
        }
    }
}

# Upload website file to S3 bucket
resource "aws_s3_bucket_object" "object" {
  bucket        = "${var.api_name}.${var.site_domain}"
  key           = "index.html"

  source        = "${path.root}/${var.site_folder}/index.html"
  content_type  = "text/html"
  cache_control = "no-cache"
  etag          = filemd5("${path.root}/${var.site_folder}/index.html")

  depends_on = [aws_s3_bucket.site, null_resource.set_callback_index_html]
}
