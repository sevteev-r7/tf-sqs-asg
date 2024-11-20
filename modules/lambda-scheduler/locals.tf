data "aws_lambda_function" "target_lambda" {
  function_name = var.lambda_name
}

locals {
  target_lambda_arn = data.aws_lambda_function.target_lambda.arn
}
