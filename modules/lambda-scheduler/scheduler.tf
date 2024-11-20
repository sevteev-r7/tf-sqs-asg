# EventBridge rule to trigger Lambda every minute
resource "aws_cloudwatch_event_rule" "lambda_trigger_rule" {
  name        = "${var.application_name}-every-minute"
  description = "Trigger Lambda every minute"
  schedule_expression = "rate(1 minute)"
}

# EventBridge target to invoke the Lambda function
resource "aws_cloudwatch_event_target" "lambda_event_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger_rule.name
  arn       = local.target_lambda_arn
  input = jsonencode({
    "AppName": "${var.application_name}",
    "SQSQueueName": "${var.sqs_queue_name}"
  })
}

# Allow EventBridge to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = var.lambda_name
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger_rule.arn
}
