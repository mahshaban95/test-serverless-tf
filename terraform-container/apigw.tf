
module "api_gateway" {
  source                 = "terraform-aws-modules/apigateway-v2/aws"
  create_api_domain_name = false
  name                   = "apigw-http-mahsh-test"
  description            = "My awesome HTTP API Gateway"
  protocol_type          = "HTTP"

  cors_configuration = {
    allow_headers = [
      "content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"
    ]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Access logs
  default_stage_access_log_format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  integrations = {
    "GET /" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
    }

    "$default" = {
      lambda_arn = module.lambda_function.lambda_function_arn
    }
  }

  depends_on = [
    module.lambda_function
  ]

}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_function.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
}

# module "api_gateway" {
#   source                 = "registry.terraform.io/terraform-aws-modules/apigateway-v2/aws"
#   create_api_domain_name = false
#   name                   = "dev-http"
#   description            = "My awesome HTTP API Gateway"
#   protocol_type          = "HTTP"

#   cors_configuration = {
#     allow_headers = [
#       "content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"
#     ]
#     allow_methods = ["*"]
#     allow_origins = ["*"]
#   }

#   # Custom domain
#   domain_name                 = null
#   domain_name_certificate_arn = null

#   # Access logs
#   default_stage_access_log_format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

#   # Routes and integrations
#   integrations = {
#     "ANY /${module.lambda_function.lambda_function_name}" = {
#       lambda_arn             = module.lambda_function.lambda_function_invoke_arn
#       payload_format_version = "2.0"
#       timeout_milliseconds   = 12000
#     }

#     "$default" = {
#       lambda_arn = module.lambda_function.lambda_function_invoke_arn
#     }
#   }

#   tags = {
#     Name = "slack-bot-http-apigateway"
#   }
# }

# resource "aws_iam_policy" "lambda_invoke_itself" {
#   name        = "lambda-invoke-itself"
#   description = "lambda_invoke_itself"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "VisualEditor0",
#       "Effect": "Allow",
#       "Action": [
#         "lambda:InvokeFunction",
#         "lambda:GetFunction"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "add_permission_for_lambda_invoke_itself" {
#   role       = module.lambda_function.lambda_role_name
#   policy_arn = aws_iam_policy.lambda_invoke_itself.arn
# }

