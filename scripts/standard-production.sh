#!/bin/bash

export SQS_QUEUE_URL=<sqs_queue_url>
export AWS_DEFAULT_REGION=<url>

while true; do
    delay=$((1 + $RANDOM % 10))
    batch=$((1 + $RANDOM % 20))
    ./producer.sh $batch
    echo "Sleeping $delay sec"
    sleep $delay
done
