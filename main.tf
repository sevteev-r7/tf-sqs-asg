provider "aws" {
  region = var.region
}

module "sqs_queue" {
  source = "./modules/sqs-queue"
  queue_name = "test-app-sevteev"
}

module "backlog_calc_lambda" {
  source = "./modules/asg-backlog-calc-lambda"
  lambda_name = "asg-instance-backlog-calc"
}

# First deploy lambda, then trigger
#module "lambda_trigger" {
#  source = "./modules/lambda-scheduler"
#  lambda_name = "asg-instance-backlog-calc"
#  application_name = "test-app-sevteev"
#  sqs_queue_name = "test-app-sevteev"
#}
