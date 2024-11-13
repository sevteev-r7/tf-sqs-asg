#!/bin/bash
# Questions? Ask @sevteev

[ "$1" != "" ] && msgs_n=$1 || { echo "Missing number of messages to consume"; exit 1; }

#set the env vars before use
[ -z "$AWS_DEFAULT_REGION" ] && { echo "Missing AWS_DEFAULT_REGION env var"; exit 1; }
[ "$SQS_QUEUE_URL" != "" ] && queue_url=$SQS_QUEUE_URL || { echo "Missing SQS_QUEUE_URL env var"; exit 1; }

export AWS_PAGER=""

batch_file=$(uuidgen)

while [ $msgs_n -ne 0 ]; do
  [ $msgs_n -lt 10 ] && batch_size=$msgs_n || batch_size=10
  IFS=$'\n' read -r -d '' -a batch < <( aws sqs receive-message --queue-url $queue_url --max-number-of-messages $batch_size | jq -r '.Messages[].ReceiptHandle' && printf '\0' )
  echo -n "Consuming batch of ${#batch[@]}: "
  echo "[" > $batch_file

  for msg in "${batch[@]}"; do
      cat <<EOT >> $batch_file
      { 
          "Id": "$(uuidgen)",
          "ReceiptHandle": "$msg"
      }$([ $msg != ${batch[${#batch[@]} - 1]} ] && echo ',')
EOT
  done
  echo "]" >> $batch_file
  aws sqs delete-message-batch --queue-url $queue_url --entries file://$batch_file > /dev/null 2>&1
  ret_code=$?
  rm -f $batch_file
  [ $ret_code -ne 0 ] &&  { echo "Failed"; exit 1; }
  msgs_n=$(echo "$msgs_n - ${#batch[@]}" | bc)
  echo "Done";
done
