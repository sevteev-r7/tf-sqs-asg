# Configure the AWS provider
provider "aws" {
  region = var.region
}

# Data source: query the list of availability zones
data "aws_availability_zones" "all" {}

resource "aws_sqs_queue" "incoming_queue" {
  name                       = var.queue_name
  max_message_size           = 256000
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 5
  receive_wait_time_seconds  = 5
}

resource "aws_launch_template" "consumer_lt" {
  name_prefix   = var.lt_name_prefix
  image_id      = var.ami_id
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "consumer_asg" {
  availability_zones        = var.az_list
  name                      = var.asg_name
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  default_instance_warmup   = 30
  launch_template {
    id      = aws_launch_template.consumer_lt.id
    version = "$Latest"
  }
  enabled_metrics = [
    "GroupInServiceInstances",
    "WarmPoolMinSize",
    "WarmPoolDesiredCapacity",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolWarmedCapacity"
  ]

  warm_pool {
    pool_state                  = "Hibernated"
    min_size                    = 2
    max_group_prepared_capacity = 10

    instance_reuse_policy {
      reuse_on_scale_in = true
    }
  }
}

resource "aws_autoscaling_policy" "consumer_scaling_policy" {
  autoscaling_group_name = var.asg_name
  name                   = var.as_policy_name
  policy_type            = "TargetTrackingScaling"
  depends_on             = [aws_autoscaling_group.consumer_asg]

  target_tracking_configuration {
    target_value = 10
    customized_metric_specification {
      metrics {
        label = "Get the queue size (the number of messages waiting to be processed)"
        id    = "m1"
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = var.queue_name
            }
          }
          stat = "Sum"
        }
        return_data = false
      }
      metrics {
        label = "Get the group size (the number of InService instances)"
        id    = "m2"
        metric_stat {
          metric {
            namespace   = "AWS/AutoScaling"
            metric_name = "GroupInServiceInstances"
            dimensions {
              name  = "AutoScalingGroupName"
              value = var.asg_name
            }
          }
          stat = "Average"
        }
        return_data = false
      }
      metrics {
        label       = "Calculate the backlog per instance"
        id          = "e1"
        expression  = "IF(m1 == 0, 1, m1 / m2)"
        return_data = true
      }
    }
  }
}
