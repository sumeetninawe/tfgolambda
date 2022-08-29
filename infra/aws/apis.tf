/*
Module to create REST APIs in API Gateway.
The code below creates a sample REST API. 
This module outputs API ARN value to be mapped to corresponding Lambda function to grant permission.

https://letsdotech.dev
*/


// ----API Gateway Resource-----------------------------
// Creates REST API in AWS API Gateway
resource "aws_api_gateway_rest_api" "aws_get_index" {
  name        = "Demo API Gateway"
  description = "Demo API Gateway"
}

// Creates API Gateway Resource
resource "aws_api_gateway_resource" "aws" {
  rest_api_id = aws_api_gateway_rest_api.aws_get_index.id
  parent_id   = aws_api_gateway_rest_api.aws_get_index.root_resource_id
  path_part   = "aws"
}

// Creates API Gateway sub-resource (Optional)
resource "aws_api_gateway_resource" "aws_raw" {
  rest_api_id = aws_api_gateway_rest_api.aws_get_index.id
  parent_id   = aws_api_gateway_resource.aws.id
  path_part   = "raw"
}

// Creates Resource method
resource "aws_api_gateway_method" "aws_raw_get_index" {
  rest_api_id   = aws_api_gateway_rest_api.aws_get_index.id
  resource_id   = aws_api_gateway_resource.aws_raw.id
  http_method   = "GET"
  authorization = "NONE"
}

// Integrates API-Resource-Method to Corresponding Lambda function to be invoked.
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.aws_get_index.id
  resource_id             = aws_api_gateway_resource.aws_raw.id
  http_method             = aws_api_gateway_method.aws_raw_get_index.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  // This is where it uses the Lambda function Invoke ARN for integration.
  uri                     = var.lambda_default_invokearn
}

// Creates method response
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.aws_get_index.id
  resource_id = aws_api_gateway_resource.aws_raw.id
  http_method = aws_api_gateway_method.aws_raw_get_index.http_method
  status_code = "200"
}

// Creates integration response
resource "aws_api_gateway_integration_response" "demo_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.aws_get_index.id
  resource_id = aws_api_gateway_resource.aws_raw.id
  http_method = aws_api_gateway_method.aws_raw_get_index.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

// ----API Gateway Deployment-----------------------------
// Automatically triggers deployment for API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.aws_get_index.id

  // Without this code, when the APIs are updated, they are not auto-deployed.
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.aws_get_index.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

// Creates deployment stage
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.aws_get_index.id
  stage_name    = "dev"
}

// ----Input / Output-----------------------------
// Accepts value from corresponding Lambda function
variable "lambda_default_invokearn" {
    type = string
}

// Supplies this value to corresponding Lambda function
output restapiarn {
    value = aws_api_gateway_rest_api.aws_get_index.execution_arn
}