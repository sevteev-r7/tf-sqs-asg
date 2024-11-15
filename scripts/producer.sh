#!/bin/bash
# Questions? Ask @sevteev

#simple check env vars and param before use
[ -z "$AWS_DEFAULT_REGION" ] && { echo "Missing AWS_DEFAULT_REGION env var"; exit 1; }
[ -z "$SQS_QUEUE_URL" ] && { echo "Missing SQS_QUEUE_URL env var"; exit 1; }
[ -z "$1" ] && { echo "Missing number of messages to produce"; exit 1; }

msgs_n=$1
queue_url=$SQS_QUEUE_URL

export AWS_PAGER=""

batch_file=$(uuidgen)

while [ $msgs_n -ne 0 ]; do
  [ $msgs_n -lt 10 ] && batch_size=$msgs_n || batch_size=10
  echo -n "Producing batch of $batch_size: "
  for j in $(seq 1 $batch_size); do
    cat  <<EOT >> $batch_file
      $([ $j -eq 1 ] && echo '['){ 
        "Id": "$(uuidgen)",
        "MessageBody": "$(uuidgen)",
        "DelaySeconds": 5,
        "MessageAttributes": {
          "NameId": {
              "DataType": "String",
              "StringValue": "$(uuidgen)"
            }
        }
      }$([ $j -eq $batch_size ] && echo ']' || echo ',')
EOT
  done
  aws sqs send-message-batch --queue-url $queue_url --entries file://$batch_file > /dev/null 2>&1
  ret_code=$?
  rm -f $batch_file
  [ $ret_code -ne 0 ] && { echo "Failed"; exit 1; }
  msgs_n=$(echo "$msgs_n - $batch_size" | bc)
  echo "Done"
done
