/*
This is a single place where we import all the Lambda functions defined in other directories of this monorepo.

https://letsdotech.dev
*/

// ----functionOne Lambda deployment-----------------------------
// The module imported below deploys the functionOne lambda function along with other infrastructure components.
// Supplies the API ARN as input. To add more functions, simply replicate the code below and map appropriate API ARN value.
module "aws_funcOne" {
  source = "./../aws/functionOne"
  apigateway_arn = module.aws_apis.restapiarn
}