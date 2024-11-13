# tf-sqs-asg

Proof of concept for SQS based EC2 autoscaling.

Files
*.tf - Terraform code for PoC infrastructure

scripts/ - scripts to produce and consume SQS messages 

Requirements
```
export AWS_DEFAULT_REGION=<aws_region>
export SQS_QUEUE_URL=<https://<sqs_queue_url>
```

## Usage
### One time use
Put 100 messages into the queue:
```
./producer.sh 100
```

Consume 30 messages from the queue: 
```
./consumer.sh 30
```

### Continuous use

Traffic generation:
```
./mock-production.sh slow normal
```
Options for 1st parameter (production speed, how fast send messages): slow|fast

Options for 2nd parameter (production intence, how many messages to send every cycle): normal|intence|spiky

Traffic consumption:
```
./mock-consumption.sh long
```
Options for the 1st parameter (what processing time is): long|short

Consumption script detects processing fleet size every cycle which ensures feedback from fleet and adjusts consumption pace. That makes simulation more realistic.
