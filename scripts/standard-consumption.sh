#!/bin/bash

export SQS_QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/042293964381/tf_sqs_poc
export AWS_DEFAULT_REGION=eu-west-1

while true; do
    delay=$((1 + $RANDOM % 10))
    batch=$((1 + $RANDOM % 50))
    ./consumer.sh $batch
    echo "Sleeping $delay sec"
    sleep $delay
done
