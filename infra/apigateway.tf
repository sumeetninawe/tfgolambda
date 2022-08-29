/*
This is a single place in root module where all the APIs are imported and deployed.
Value of Invoke ARN for corresponding Lambda function is supplied.

https://letsdotech.dev
*/

// ----API Gateway-----------------------------
// Replicate this code to build more API gateways tied to corresponding Lambda function invocations.
module "aws_apis" {
  source = "./aws"
  lambda_default_invokearn = module.aws_funcOne.aws_getindex_invokearn
}