data "aws_ecr_authorization_token" "token" {}

provider "aws" {
  region = "eu-west-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

provider "docker" {
  registry_auth {
    address  = "867670979166.dkr.ecr.eu-west-1.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name  = "my-lambda-mahsh-test"
  create_package = false
  publish        = true

  # Container Image
  image_uri    = module.docker_image.image_uri
  package_type = "Image"

  # attach_tracing_policy = true
  # Allowed triggers
  # allowed_triggers = {
  #   AllowExecutionFromAPIGateway = {
  #     service    = "apigateway"
  #     source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
  #     stage      = ""
  #   }
  # }
  # allowed_triggers = {
  #   APIGatewayAny = {
  #     service    = "apigateway"
  #     source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/${module.lambda_function.lambda_function_name}"
  #     stage      = ""
  #   }
  # }

}

module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = "my-cool-ecr-repo-mahsh-test"
  source_path     = "../src"
}