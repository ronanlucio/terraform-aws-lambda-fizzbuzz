output "cognito_user_pool_id" {
    value = aws_cognito_user_pool.pool.id
}

output "cognito_user_pool_client_id" {
    value = aws_cognito_user_pool_client.client.id
}

output "cognito_user_pool_name" {
    value = aws_cognito_user_pool.pool.name
}

output "cognito_user_pool_arn" {
    value = aws_cognito_user_pool.pool.arn
}
