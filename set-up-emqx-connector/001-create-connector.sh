#!/bin/bash
# set -ex

## Get the OS
OS_TYPE=$(uname)

create_connector() {
    curl -X POST http://0.0.0.0:18083/api/v5/connectors \
        -u ${EMQX_API_KEY}:${EMQX_SECRET_KEY} \
        -H "Content-Type: application/json" \
        -d '{
            "name": "postgresql_timescaledb_connector",
            "description": "Connector to Postgresql 15 with TimescaleDB",
            "type": "timescale",
            "enable": true,
            "server": "'${POSTGRES_HOST}':'${PGPORT}'",
            "database": "'${POSTGRES_DB}'",
            "username": "'${POSTGRES_ADMIN_USER}'",
            "password": "'${POSTGRES_ADMIN_PASSWORD}'",
            "pool_size": 8,
            "ssl": {
            "enable": false,
            "verify": "verify_peer",
            "depth": 10,
            "secure_renegotiate": true,
            "reuse_sessions": true,
            "hibernate_after": "5s",
            "log_level": "notice",
            "ciphers": [],
            "versions": ["tlsv1.3", "tlsv1.2"]
            }
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
            export POSTGRES_HOST="postgresql-broker"
            create_connector
            ;;
        "Linux")
            set_up_env_variable_file
            source ../settings.env
            export POSTGRES_HOST="0.0.0.0"
            create_connector
            ;;
        *)
            echo "System isn't supported by this script: ${OS_TYPE}"
            echo "Please contact to the support team."
            exit 1
            ;;
    esac
    echo "..."
    echo "Connector to Postgresql created..."
}

main