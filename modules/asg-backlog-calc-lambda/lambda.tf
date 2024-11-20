# IAM role for Lambda function execution
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-${var.lambda_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM policy for CloudWatch access (Lambda will need to access CloudWatch metrics)
resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name        = "${var.lambda_name}-lambda-policy"
  description = "Policy to allow Lambda to read and write CloudWatch metrics and describe ASG"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${local.region}:${local.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${var.lambda_name}:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:Get*",
                "autoscaling:DescribeAutoScalingGroups"
            ],
            "Resource": "*"
        }
    ]
})
}

# Attach the policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./modules/asg-backlog-calc-lambda/lambda_function.py"
  output_path = "./modules/asg-backlog-calc-lambda/lambda_function_payload.zip"
}

# Lambda function creation
resource "aws_lambda_function" "lambda_function" {
#  depends_on = [data.archive_file.lambda]
  function_name = var.lambda_name
  role = aws_iam_role.lambda_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.8"
  filename = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
}
