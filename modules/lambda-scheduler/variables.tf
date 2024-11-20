variable "application_name" {
  description = "Name of an application as it's defined in Spinnaker, e.g. processregistryapp"
}

variable "sqs_queue_name" {
  description = "Name of SQS queue that the application consumes from"
}

variable "lambda_name" {
  description = "Name if a Lambda function that calculates ASG instance backlog"
  default     = "asg-backlog-calc"
}
