# tf-sqs-asg

Proof of concept for SQS based EC2 autoscaling.

Files
- *.tf - Terraform code for PoC infrastructure
- scripts/ - scripts to produce and consume SQS messages 

Requirements
```
export AWS_DEFAULT_REGION=<aws_region>
export SQS_QUEUE_URL=<sqs_queue_url>
```
