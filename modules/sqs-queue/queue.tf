resource "aws_sqs_queue" "incoming_queue" {
  name                       = var.queue_name
  max_message_size           = 256000
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 5
  receive_wait_time_seconds  = 5
}
