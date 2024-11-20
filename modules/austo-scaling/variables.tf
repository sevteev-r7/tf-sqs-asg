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

variable "instance_type" {
  description = "EC2 instance type"
  default = "t2.micro"
}

variable "asg_name" {
  description = "ASG name"
  default     = "tf_sqs_poc"
}

variable "as_policy_name" {
  description = "AS policy name"
  default     = "tf_sqs_poc"
}

variable "asg_min" {
  description = "ASG min instances"
  default = 1
}

variable "asg_max" {
  description = "ASG max instances"
  default = 1
}

variable "asg_wp_min" {
  description = "ASG warm pool min instances"
  default = 0
}

variable "asg_wp_max" {
  description = "ASG warm pool max instances"
  default = 0
}

variable "instance_backlog" {
  description = "Backlog of one instance"
  default = 10
}