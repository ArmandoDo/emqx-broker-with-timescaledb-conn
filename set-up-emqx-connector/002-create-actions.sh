#!/bin/bash
# set -ex

## Get the OS
OS_TYPE=$(uname)

### Request to set up the client event action
create_client_events_action() {
    curl -X POST http://localhost:18083/api/v5/actions \
        -u ${EMQX_API_KEY}:${EMQX_SECRET_KEY} \
        -H "Content-Type: application/json" \
        -d '{
        "name": "insert_client_event",
        "type": "timescale",
        "enable": true,
        "connector": "postgresql_timescaledb_connector",
        "resource_opts": {
            "batch_size": 1,
            "worker_pool_size": 16,
            "max_buffer_bytes": "256MB",
            "batch_time": "50ms",
            "inflight_window": 100,
            "request_ttl": "45s"
        },
        "parameters": {
            "sql": "INSERT INTO emqx_client_events (time, clientid, event) VALUES (TO_TIMESTAMP((${timestamp}::bigint)/1000), ${clientid}, ${event})"
        },
        "description": "Insert client events like connect/disconnect"
    }'

}

### Request to set up the units status action
create_units_status_action() {
    curl -X POST http://localhost:18083/api/v5/actions \
        -u ${EMQX_API_KEY}:${EMQX_SECRET_KEY} \
        -H "Content-Type: application/json" \
        -d '{
            "name": "insert_unit_status",
            "type": "timescale",
            "enable": true,
            "connector": "postgresql_timescaledb_connector",
            "resource_opts": {
                "batch_size": 1,
                "worker_pool_size": 16,
                "max_buffer_bytes": "256MB",
                "batch_time": "50ms",
                "inflight_window": 100,
                "request_ttl": "45s"
            },
            "parameters": {
                "sql": "INSERT INTO units_status (time, topic, qos, retain, dup, dispenser_id, session_id, energy_kwh, voltage_v, current_a, temperature_c, status, station_id) VALUES (TO_TIMESTAMP((${time} :: bigint)/1000), ${topic}, ${qos}, ${retain}, ${dup}, ${dispenser_id}, ${session_id}, ${energy_kwh}, ${voltage_v}, ${current_a}, ${temperature_c}, ${status}, ${station_id})"
            },
            "description": "Insert MQTT command messages to PostgreSQL"
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
            create_client_events_action
            create_units_status_action
            ;;
        "Linux")
            set_up_env_variable_file
            source ../settings.env
            create_client_events_action
            create_units_status_action
            ;;
        *)
            echo "System isn't supported by this script: ${OS_TYPE}"
            echo "Please contact to the support team."
            exit 1
            ;;
    esac

    echo "Actions created..."
}

main