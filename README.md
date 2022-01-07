# FizzBuzz Challenge

## Overview

This project creates a FizzBuzz function (for testing purposes) on AWS Lambda, and exposes it via AWS API Gateway via Cognito.

### Implementation and Tech Stack

- REST API is backed by AWS Lambda Function served via AWS API Gateway
- Authentication was implemented via Amazon Cognito
  - You first need to sign-up, so you'll be able to log in and make API calls via FizzBuzz web page
  - After logged in, Cognito will redirect the user to FizzBuzz webpage, passing a id_token as GET parameter. This id_token needs to be informed as (Bearer) Authorization header in order to have the request authorized
- Deployment happens via GitHub Actions
  - Every code pushed to GitHub (any repository, but main), triggers CI pipeline to test nodejs code and outputs a **terraform plan** command in order to validate what's going to be changed in the infrastructure when merged to main branch
  - Every code pushed to GitHub's main branch, triggers a nodejs code **test** and a **terraform apply** command in order to deploy the desired underlying infrastructure
  - Credentials are stored on GitHub Secrets
  - ESLint is being used as the linter testing tool for nodejs code
- Amazon CloudWatch for logging
- AWS X-Ray for tracing
- AWS WAF for rate-limit
- Amazon S3 is being used to host the front-end web page
- Cloudflare is being used to create a static domain name to host the front-end web page, and a SSL certificate to serve front-end web page via HTTPS
- Terraform is being used for Infrastructure as Code. The entire infrastructure is being deployed using terraform and GitHub Actions

## Requirements

- AWS Account
- Git
- Terraform >= 1.0.1
- NodeJS 14.x
- npm
- ESLint

## USAGE

1. Provision Terraform backend bucket and lock table

```
cd terraform/backend-terraform
terraform plan -var-file="../../terraform.tfvars"
terraform apply -var-file="../../terraform.tfvars"
terraform output
```

2. Initializing Terraform requires passing a few parameters

```
terraform init \
    -backend-config="bucket=fizzbuzz-backend-terraform" \
    -backend-config="region=us-east-1" \
    -backend-config="dynamodb_table=fizzbuzz-terraform-locks" \
    -backend-config="key=fizzbuzz/terraform.tfstate"
```

Now you're ready to push your code and have the underlying infrastucture and API provisioned and deployed.

## Additional Details

### Rate-limit

NOTE: AWS WAF service is being used for rate-limit 500 requests per 5-minute.

## Development Environment

### Environment Variables

Development environment relies on existing environment variables 

- AWS_ACCESS_KEY
- AWS_SECRET_ACCESS_KEY
- CLOUDFLARE_API_TOKEN

For this challange we're setting these variables on GitHub Secrets.


## Deployment

### CI/CD

- We're using **GitHub Action** for Continuous Integration and Continuous Deployment
- Every code push to **any** branch (but main) triggers two GitHub Actions workflows:
  - **App Test** execute tests for lambda function
  - **Terraform Plan** execute a "terraform plan" command and outputs it for validation purposes
- Every code push to **main** or **master** branch triggers a "terraform apply" command to update the underlying infrastructure

### Deploy

To deploy changes and apply underlying infrastructure, just merge or push it to **main** branch

### Check Pipeline Execution

To check pipeline execution for success or errors, access project's GitHub Action.

## Tests

### Isolated invoking a lambda function:

```
aws lambda invoke \
    --region=us-east-1 \
    --cli-binary-format raw-in-base64-out \
    --function-name fizzbuzz \
    --payload '{"body": "{\"number\": \"5\"}"}' \
    response.json

cat response.json
```

NOTE: Using Lambda on PROXY mode requires sending required parameters under a JSON "body" field.

### Authenticate to Cognito

Authentication happens via Cognito accessing the URL below. For the current implementation, the front-end web page will automatically redirects the user to Cognito authentication URI in case it doesn't find the id_token parameter on the URL's query string.


### Invoking fizzbuzz REST API

To invoke FizzBuzz REST API you must inform a Authorization token.

1. Log in via Amazon Cognito or accessing the front-end web page
2. After signed-up and logged in, you'll be redirected to the front-end web page. Copy the entire URI and extract the **id_token** parameter
3. Now you can store it into as environment, and make requests using **curl** command

#### Example using curl via command-link

```
curl --location --request POST 'https://zopibuoj9b.execute-api.us-east-1.amazonaws.com/dev/fizzbuzz' \
--header 'Authorization: Bearer PASTE_YOUR_ID_TOKEN_HERE' \
--header 'Content-Type: application/json' \
--data-raw '{"number": "5"}'
```

#### Example using Postman

Alternatively, you can past your ID_TOKEN parameter into Postman and send a POST request:

![Postman Authorization screenshot](./images/screenshot_postman_authorization.png)

![Postman Body screenshot](./images/screenshot_postman_body.png)
