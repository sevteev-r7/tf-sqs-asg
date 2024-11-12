#!/bin/bash

export SQS_QUEUE_URL=<sqs_queue_url>
export AWS_DEFAULT_REGION=<aws_region>

while true; do
    delay=$((1 + $RANDOM % 10))
    batch=$((1 + $RANDOM % 50))
    ./consumer.sh $batch
    echo "Sleeping $delay sec"
    sleep $delay
done
