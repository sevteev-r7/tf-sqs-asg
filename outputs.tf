output "aws_region" {
  value = var.region
}

output "sqs_queue_url" {
  value = aws_sqs_queue.incoming_queue.url
}
