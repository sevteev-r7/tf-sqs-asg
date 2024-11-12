resource "aws_cloudwatch_dashboard" "tf-sqs-poc" {
  dashboard_name = "tf-sqs-poc"

  dashboard_body = jsonencode({
    "widgets": [
        {
            "height": 5,
            "width": 24,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "${var.queue_name}", { "region": "${var.region}" } ],
                    [ ".", "ApproximateAgeOfOldestMessage", ".", ".", { "region": "${var.region}" } ],
                    [ ".", "NumberOfMessagesReceived", ".", ".", { "region": "${var.region}", "stat": "Sum" } ],
                    [ ".", "NumberOfMessagesDeleted", ".", ".", { "region": "${var.region}", "stat": "Sum" } ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "${var.region}",
                "period": 60,
                "stat": "Maximum"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 5,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "${var.asg_name}", { "region": "${var.region}" } ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "${var.region}",
                "period": 60,
                "stat": "Maximum"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 5,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/SQS", "NumberOfMessagesSent", "QueueName", "${var.queue_name}" ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "${var.region}",
                "stat": "Sum",
                "period": 60
            }
        }
    ]
  })
}
