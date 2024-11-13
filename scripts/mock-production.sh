#!/bin/bash

export SQS_QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/<AWS account ID>/tf_sqs_poc
export AWS_DEFAULT_REGION=eu-west-1

#delay
slow=30
fast=3

#batch size
normal=20
intence=50
spiky=100

case "$1" in
    "slow")
        delay_limit=$slow
    ;;
    "fast")
        delay_limit=$fast
    ;;
    *)
        echo "Wrong delay value"
        exit 1
    ;;
esac

case "$2" in
    "normal")
        batch_limit=$normal
    ;;
    "intence")
        batch_limit=$intence
    ;;
    "spiky")
        batch_limit=$spiky
    ;;
    *)
        echo "Wrong batch value"
        exit 1
    ;;
esac


while true; do
    delay=$((1 + $RANDOM % $delay_limit))
    batch=$((1 + $RANDOM % $batch_limit))
    ./producer.sh $batch
    echo "Sleeping $delay sec"
    sleep $delay
done
