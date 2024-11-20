import boto3
import time

from math import ceil

def is_event_valid(event):
    if not event.get('AppName') or not event.get('SQSQueueName'):
        return False
    
    return True


def get_asg_by_app(app_name):
    # Create an AutoScaling client
    autoscaling = boto3.client('autoscaling')
    asg_data = autoscaling.describe_auto_scaling_groups()

    # Determine the ASG name of the latest version of the application
    asgs = [
        asg for asg in asg_data['AutoScalingGroups'] 
        if app_name in asg['AutoScalingGroupName']
        and [metric for metric in asg['EnabledMetrics'] if metric['Metric'] == 'GroupInServiceInstances']
    ]

    asg_names = [asg['AutoScalingGroupName'] for asg in asgs]

    if not asg_names:
        return

    return max(asg_names)


def lambda_handler(event, context):

    if not is_event_valid(event):
        print(f'Missing input parameter. Both "AppName" and "SQSQueueName" must be defined.')
        return {
            'statusCode': 422,
            'body': f'Missing/incorrect input parameter'
        }
    
    app_name = event.get('AppName')
    sqs_queue_name = event.get('SQSQueueName')

    asg_name = get_asg_by_app(app_name)

    if not asg_name:
        print(f'No Auto Scaling Group found for the application "{app_name}". It might not exist, or the "GroupInServiceInstances" metric could be missing.')
        return {
            'statusCode': 404,
            'body': f'No Auto Scaling Group found'
        }

    # Create a CloudWatch client
    cloudwatch = boto3.client('cloudwatch')

    # Define the metric names and the namespace
    metric_1_name = 'ApproximateNumberOfMessagesVisible'
    metric_1_namespace = 'AWS/SQS'
    metric_2_name = 'GroupInServiceInstances'
    metric_2_namespace = 'AWS/AutoScaling'
    metric_3_name = 'ASGInstanceBacklog'
    metric_3_namespace = 'AWS/AutoScaling'

    # Set the time range to fetch the metrics
    end_time = int(time.time())
    start_time = end_time - 60  # 1 minute before now
    
    # Retrieve Metric 1
    metric_1_response = cloudwatch.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'm1',
                'MetricStat': {
                    'Metric': {
                        'Namespace': metric_1_namespace,
                        'MetricName': metric_1_name,
                        'Dimensions': [
                            {
                                'Name': 'QueueName',
                                'Value': sqs_queue_name  # Replace with your dimension value
                            }
                        ]
                    },
                    'Period': 60,  # Aggregation period in seconds
                    'Stat': 'Average'
                },
                'ReturnData': True
            }
        ],
        StartTime=start_time,
        EndTime=end_time
    )

    # Retrieve Metric 2
    metric_2_response = cloudwatch.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'm2',
                'MetricStat': {
                    'Metric': {
                        'Namespace': metric_2_namespace,
                        'MetricName': metric_2_name,
                        'Dimensions': [
                            {
                                'Name': 'AutoScalingGroupName',
                                'Value': asg_name  # Replace with your dimension value
                            }
                        ]
                    },
                    'Period': 60,  # Aggregation period in seconds
                    'Stat': 'Average'
                },
                'ReturnData': True
            }
        ],
        StartTime=start_time,
        EndTime=end_time
    )

    # Extract the values for Metric 1 and Metric 2
    try:
        metric_1_value = metric_1_response['MetricDataResults'][0]['Values'][0]
        metric_2_value = metric_2_response['MetricDataResults'][0]['Values'][0]

        # Multiply the two metric values
        result_value = ceil(metric_1_value / metric_2_value) if metric_2_value > 0 else 0

        # Log the result
        print(f"App: {app_name}, ASG: {asg_name}, SQS_Queue: {sqs_queue_name}, {metric_1_name}: {metric_1_value}, {metric_2_name}: {metric_2_value}, {metric_3_name}: {result_value}")

        # Send the result to CloudWatch as a new custom metric
        cloudwatch.put_metric_data(
            Namespace=metric_3_namespace,
            MetricData=[
                {
                    'MetricName': metric_3_name,
                    'Dimensions': [
                        {
                            'Name': 'ASGNamePrefix',
                            'Value': app_name  # Replace with your dimension value
                        }
                    ],
                    'Value': result_value,
                    'Unit': 'None'
                }
            ]
        )
    except Exception as e:
        print(f"Error retrieving or processing metrics: {e}")

    return {
        'statusCode': 200,
        'body': f'Successfully processed and sent multiplied metric to CloudWatch.'
    }
