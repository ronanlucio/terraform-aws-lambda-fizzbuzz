# Create an API Gateway
resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "${var.api_name}_lambda_gw"
}

# Create the "/fizzbuzz" resource
resource "aws_api_gateway_resource" "fizzbuzz_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part = "fizzbuzz"
}

# Create fizzbuzz POST method
resource "aws_api_gateway_method" "fizzbuzz_method" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.fizzbuzz_resource.id
  http_method = "POST"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id
  authorization_scopes = ["email"]

  request_parameters = {
    "method.request.path.proxy" = true,
  }
}

# Configure method integretion
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.fizzbuzz_resource.id
  http_method = aws_api_gateway_method.fizzbuzz_method.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.fizzbuzz.invoke_arn
}

# Deploy the REST API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.fizzbuzz_resource.id,
      aws_api_gateway_method.fizzbuzz_method.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

# Define a DEV resource
resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id

  xray_tracing_enabled = "true"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.fizzbuzz.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

  depends_on = [aws_cloudwatch_log_group.fizzbuzz]
}

# Logging settings for the method
resource "aws_api_gateway_method_settings" "fizzbuzz_post" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  method_path = "${trimprefix(aws_api_gateway_resource.fizzbuzz_resource.path, "/")}/POST"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

# Provides an api gateway authorizer
resource "aws_api_gateway_authorizer" "api_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  provider_arns = [var.cognito_user_pool_arn]
}

# Enable CORS on the api gateway
module "enable_cors" {
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"

  api      = aws_api_gateway_rest_api.lambda_api.id
  resource = aws_api_gateway_resource.fizzbuzz_resource.id

  methods = ["POST"]
}