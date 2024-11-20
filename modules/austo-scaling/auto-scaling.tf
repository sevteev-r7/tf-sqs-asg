resource "aws_launch_template" "consumer_lt" {
  name_prefix   = var.lt_name_prefix
  image_id      = var.ami_id
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "consumer_asg" {
  availability_zones        = var.az_list
  name                      = var.asg_name
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  default_instance_warmup   = 30
  launch_template {
    id      = aws_launch_template.consumer_lt.id
    version = "$Latest"
  }
  enabled_metrics = ["GroupInServiceInstances"]

  warm_pool {
    pool_state                  = "Hibernated"
    min_size                    = var.asg_wp_min
    max_group_prepared_capacity = var.asg_wp_max

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
    target_value = var.instance_backlog
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
        expression  = "IF(m2 == 0, 0, m1 / m2)"
        return_data = true
      }
    }
  }
}
