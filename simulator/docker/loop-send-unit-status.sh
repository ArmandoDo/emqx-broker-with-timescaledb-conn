#!/bin/sh
# set -ex

# Env variables
: "${EMQX_DEVELOPER_USERNAME:?Need to set EMQX_DEVELOPER_USERNAME}"
: "${EMQX_DEVELOPER_PASSWORD:?Need to set EMQX_DEVELOPER_PASSWORD}"
: "${DISPENSER_ID:?Need to set DISPENSER_ID}"
: "${QOS:=0}"
: "${RETAIN:=false}"
: "${STATION_ID:=ST-0001}"
: "${SLEEP_SECONDS:=5}"

while true; do
    DATE=$(date +%Y%m%d)
    SESSION_ID="SES-${DATE}-${DISPENSER_ID}-001"
    ENERGY_KWH=$(awk 'BEGIN{srand(); printf "%.1f\n", rand()*10}')
    VOLTAGE_V=$(awk 'BEGIN{srand(); printf "%.1f\n", rand()*300}')
    CURRENT_A=$(awk 'BEGIN{srand(); printf "%.1f\n", rand()*20}')
    TEMPERATURE_C=$(awk 'BEGIN{srand(); printf "%.1f\n", rand()*100}')

    PAYLOAD=$(cat <<EOF
{
  "dispenser_id": "$DISPENSER_ID",
  "session_id": "$SESSION_ID",
  "energy_kwh": $ENERGY_KWH,
  "voltage_v": $VOLTAGE_V,
  "current_a": $CURRENT_A,
  "temperature_c": $TEMPERATURE_C,
  "status": "charging",
  "station_id": "$STATION_ID"
}
EOF
)

    TOPIC="sst/units/${DISPENSER_ID}/status"

    mqttx pub --hostname emqx-broker --username $EMQX_DEVELOPER_USERNAME --password $EMQX_DEVELOPER_PASSWORD  \
        --port 1883 --client-id mqttx-cli-$DISPENSER_ID \
        --topic $TOPIC --qos $QOS --retain $RETAIN --message "$PAYLOAD" || exit 1

    echo "Published to topic $TOPIC: $PAYLOAD."
    echo "Sleeping for $SLEEP_SECONDS seconds..."
    echo "..."

    sleep "$SLEEP_SECONDS"
done
