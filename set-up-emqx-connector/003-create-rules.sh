#!/bin/bash
# set -ex

## Get the OS
OS_TYPE=$(uname)

### Request to set up the client event rule
create_client_events_rule() {
    curl -X POST http://localhost:18083/api/v5/rules \
        -u ${EMQX_API_KEY}:${EMQX_SECRET_KEY} \
        -H "Content-Type: application/json" \
        -d '{
            "id": "rule_log_client_events",
            "name": "Log client events",
            "sql": "SELECT clientid, event, timestamp FROM \"$events/client_connected\", \"$events/client_disconnected\"",
            "enable": true,
            "description": "Store connection events to emqx_client_events table",
            "actions": ["timescale:insert_client_event"]
        }'

}

### Request to set up the units status rule
create_units_status_rule() {
    curl -X POST http://localhost:18083/api/v5/rules \
        -u ${EMQX_API_KEY}:${EMQX_SECRET_KEY} \
        -H "Content-Type: application/json" \
        -d '{
            "id": "rule_store_unit_mqtt_msg",
            "name": "Store status of units",
            "sql": "SELECT timestamp AS time, topic AS topic, qos AS qos, flags.retain AS retain, flags.dup AS dup, payload.dispenser_id AS dispenser_id, payload.session_id AS session_id, payload.energy_kwh AS energy_kwh, payload.voltage_v AS voltage_v, payload.current_a AS current_a, payload.temperature_c AS temperature_c, payload.status AS status, payload.station_id AS station_id FROM \"sst/units/+/status\"",
            "enable": true,
            "description": "Insert MQTT messages into units_status table",
            "actions": ["timescale:insert_unit_status"]
        }'
}

# Set up the environment variable file .env
set_up_env_variable_file() {
    if ! source ../.env; then
        echo "Missing ../.env file with the environment variables. Please create the .env file"
        exit 1
    fi
}

## Main function
main() {
    echo "${OS_TYPE} detected. Creating the connector to Postgresql..."
    # Verify the OS
    case "${OS_TYPE}" in
        "Darwin")
            set_up_env_variable_file
            source ../settings.env
            create_client_events_rule
            create_units_status_rule
            ;;
        "Linux")
            set_up_env_variable_file
            source ../settings.env
            create_client_events_rule
            create_units_status_rule
            ;;
        *)
            echo "System isn't supported by this script: ${OS_TYPE}"
            echo "Please contact to the support team."
            exit 1
            ;;
    esac

    echo "Rules created"
}

main