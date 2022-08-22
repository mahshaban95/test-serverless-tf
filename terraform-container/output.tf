output "lambda-url" {
  description = "lambda_url"
  value       = "${module.api_gateway.apigatewayv2_api_api_endpoint}/${module.lambda_function.lambda_function_name}"
}


output "api-address-arn" {
  description = "apigatewayv2_api_execution_arn"
  value       = module.api_gateway.apigatewayv2_api_execution_arn
}
