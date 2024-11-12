variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "az_list" {
  description = "availability zones"
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "queue_name" {
  description = "queue name"
  default     = "tf_sqs_poc"
}

variable "lt_name_prefix" {
  description = "launch template prefix"
  default     = "tf_sqs_poc_"
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-03ca36368dbc9cfa1"
}

variable "asg_name" {
  description = "ASG name"
  default     = "tf_sqs_poc"
}

variable "as_policy_name" {
  description = "AS policy name"
  default     = "tf_sqs_poc"
}
