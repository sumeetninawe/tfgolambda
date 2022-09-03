# tfgolambda

## Step 1: Write the go code
Create a repository similar to aws/functionOne. Copy if required.
Write all the go code required for the Lambda function within the code directory.
While doing this, note that the only job of main function is to call the HandleRequest function. Write the code accordingly.
The intension of having functionOne and other lambda function code within the aws directory, is that I plan to accommodate additional FaaS platforms in the future.

## Step 2: Update Terraform file (optional step)
Update the zip_file, and zip_ref local variables in the main.tf file.
Rest of the code may remain the same.
If you are okay with using the same name for all binaries and zip files to be uploaded to Lambda, skip this step.

## Step 3: Update build.sh in root directory.
Build.sh builds the go code for each function.
Create copies of the code snippet included in the current build.sh file, to build binaries for all the functions created.
Adjust the path and file names in the copies.

## Step 4: Update the terraform scripts.
Navigate to /infra and update lambda.tf file to import newly created Terraform module for new function in Step 2.
If this needs to be tied to an API, create the APIs in /infra/aws/apis.tf file. If not required skip it, and do not supply the apigateway_arn input.

## Step 5: Build the go code for all functions.
In the root directory, run Build.sh

## Step 6: Repeat above steps for additional functions.

## Step 6: Deploy
Navigate to infra directory.
Run terraform apply.

## Result:
It should create all the lambda functios created above, along with any API gateway configuration. Test the functions and APIs.
