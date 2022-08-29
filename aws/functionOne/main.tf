/*
Terraform module to manage this lambda function. It zips the Go binary, implements appropriate permissions, and creates a Lambda function in AWS. 
It exposes the invoke arn which is used by the Terraform code in infra root module.

https://letsdotech.dev
*/

// ----Zip file creation-----------------------------
// Local variables are defined mainly to manage the file and handler names.
locals {
  function_name = "func_one"
  handler       = "main"
  runtime       = "go1.x"
  timeout       = 6
  zip_file      = "./func_one"
  zip_ref       = "./../aws/functionOne/func_one"
}

// Data resource used to create a zip file of binary which is required by the Lambda function.
data "archive_file" "zip" {
  excludes = [
    ".env",
    ".terraform",
    ".terraform.lock.hcl",
    "main.tf",
    "docker-compose.yml",
    "terraform.tfstate",
    "terraform.tfstate.backup",
    "go.mod",
    "go.sum",
    ".go"
  ]
  // All of the Go code for this Lambda function is developed within /code sub-directory
  source_dir = "${path.module}/code"
  type       = "zip"
  // Path where the resulting zip file is stored. Naming convention of all the files including zip file is managed in the local variables.
  output_path = "${path.module}/${local.zip_file}"
}

// ----IAM Roles and Policies-----------------------------
// AWS IAM Policy document for AssumeRole action for this Lambda function.
data "aws_iam_policy_document" "default" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

// Create the role using the policy described above.
resource "aws_iam_role" "default" {
  assume_role_policy = data.aws_iam_policy_document.default.json
}

// Attaching Lambda Basic Execution Role to the role created above for Lambda function.
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.default.name
}

// ----Lambda function-----------------------------
// Terraform resource to create the Lambda function itself. Most of the values are derived from local variables defined above.
resource "aws_lambda_function" "default" {
  function_name = local.function_name
  handler       = local.handler
  runtime       = local.runtime
  timeout       = local.timeout

  filename         = local.zip_ref
  source_code_hash = data.archive_file.zip.output_base64sha256

  role = aws_iam_role.default.arn
}

// ----Permission for API Gateway-----------------------------
// Terraform Lambda permission resource to allow API gateway (managed from /infra root).
// Depends on the input variable apigateway_arn supplied by the corresponding "api gateway" module. In this case - ./../infra/aws
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.apigateway_arn}/*/*/*"
}

//// ----Input / Output-----------------------------
variable apigateway_arn {
  type = string
}

// This variable is used by the corresponding "api gateway" module for integrating the API to this Lambda function
output "aws_getindex_invokearn" {
  value = aws_lambda_function.default.invoke_arn
}
