#!/bin/bash

export SQS_QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/<AWS account ID>/tf_sqs_poc
export AWS_DEFAULT_REGION=eu-west-1

long=20
short=3

case "$1" in
    "long")
        processing_time=$long
    ;;
    "short")
        processing_time=$short
    ;;
    *)
        echo "Incorrect processing time"
        exit 1
    ;;
esac


while true; do
    fleet_size=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters Name=instance-state-name,Values=running | jq -r '.[]' | wc -l)
    backlog=$(echo "$fleet_size * 10" | bc)
    delay=$((1 + $RANDOM % $processing_time))
    batch=$((1 + $RANDOM % $backlog))
    echo "$fleet_size workers"
    ./consumer.sh $batch
    echo "Sleeping $delay sec"
    sleep $delay
done
