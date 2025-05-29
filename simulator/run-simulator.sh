#!/bin/bash
# set -ex

APP_NAME="mqttx-cli"
APP_TAG="v1.12.0-beta.2"

# Default values
qos=0
retain=false
station_id="ST-0001"
sleep_seconds=5

# Set up the environment variable file .env
if ! source ../.env; then
    echo "Missing ../.env file with the environment variables. Please create the .env file"
    exit 1
fi

source ../settings.env

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dispenser_id) dispenser_id="$2"; shift ;;
        --qos) qos="$2"; shift ;;
        --retain) retain="$2"; shift ;;
        --station_id) station_id="$2"; shift ;;
        --sleep_seconds) sleep_seconds="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate required flag
if [[ -z "$dispenser_id" ]]; then
    echo "Error: --dispenser_id is required"
    exit 1
fi


docker run -it --rm \
  --network emqx_network \
  --name mqttx-cli-${dispenser_id} \
  -e DISPENSER_ID=${dispenser_id} \
  -e QOS=${qos} \
  -e RETAIN=${retain} \
  -e STATION_ID=${station_id} \
  -e SLEEP_SECONDS=${sleep_seconds} \
  -e EMQX_DEVELOPER_USERNAME=${EMQX_DEVELOPER_USERNAME} \
  -e EMQX_DEVELOPER_PASSWORD=${EMQX_DEVELOPER_PASSWORD} \
   ${REGISTRY_NAME}/${APP_NAME}:${APP_TAG} \
  sh /app/loop-send-unit-status.sh
