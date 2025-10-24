#!/bin/bash

# A simple script that acts as kafka producer and sends data to kafka topic

while true; do

    # EVENT_TYPE -- 0 For API, 1 for GPU
    EVENT_TYPE=$(($RANDOM % 1))
    EVENT_ID=evt_$((RANDOM % 200))

    TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
    COST=$(($RANDOM % 5 + 1)).$(($RANDOM % 99))

    if [[ $EVENT_TYPE -eq 0 ]]; then
        SOURCE="api_call"
        TEAM="api-team-$(($RANDOM % 3 + 1))"
        # Generating a random project name (A-Z)
        PROJECT="project-$(echo -e "\\x$(printf %x $(($RANDOM % 26 + 65)))")"
        DURATION=$(($RANDOM % 600 + 60))s
        DETAILS="{\"team\": \"$TEAM\", \"project\": \"$PROJECT\", \"duration_seconds\": $DURATION}"
    else
        SOURCE="gpu_training_job"
        TEAM="ml-team-$(($RANDOM % 2 + 1))"
        # Generating a random project name (A-Z)
        PROJECT="project-$(echo -e "\\x$(printf %x $(($RANDOM % 26 + 75)))")"
        DURATION=$(($RANDOM % 1000 + 100))s
        DETAILS="{\"team\": \"$TEAM\", \"project\": \"$PROJECT\", \"duration_seconds\": $DURATION}"
    fi

    JSON_MSG="{\"event_id\": \"$EVENT_ID\", \"timestamp\": \"$TIMESTAMP\", \"source\": \"$SOURCE\", \"cost\": $COST, \"details\": $DETAILS}"
    
    # Send the json msg to kafka topic
    echo "$JSON_MSG" | /opt/bitnami/kafka/bin/kafka-console-producer.sh \
    --broker-list my-kafka-cluster-kafka-brokers.kafka.svc.cluster.local:9092 \
    --topic ai-costs

    sleep 10

done