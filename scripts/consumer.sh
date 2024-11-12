#!/bin/bash
# Questions? Ask @sevteev

[ "$1" != "" ] && msgs_n=$1 || { echo "Missing number of messages to consume"; exit 1; }

#set the env vars before use
[ "$AWS_DEFAULT_REGION" != "" ] && region=$AWS_DEFAULT_REGION || { echo "Missing AWS_DEFAULT_REGION env var"; exit 1; }
[ "$SQS_QUEUE_URL" != "" ] && queue_url=$SQS_QUEUE_URL || { echo "Missing SQS_QUEUE_URL env var"; exit 1; }

export AWS_PAGER=""

batch_file=$(uuidgen)

while [ $msgs_n -ne 0 ]; do
  [ $msgs_n -lt 10 ] && batch_size=$msgs_n || batch_size=10
  IFS=$'\n' read -r -d '' -a batch < <( aws --region $region sqs receive-message --queue-url $queue_url --max-number-of-messages $batch_size | jq -r '.Messages[].ReceiptHandle' && printf '\0' )
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
  #msgs_n=$(echo "$msgs_n - ${#batch[@]}" | bc)  
  aws --region $region sqs delete-message-batch --queue-url $queue_url --entries file://$batch_file > /dev/null 2>&1 \
      && { rm -f $batch_file; msgs_n=$(echo "$msgs_n - ${#batch[@]}" | bc); echo "Done"; } || { echo "Failed"; exit 1; }
done
