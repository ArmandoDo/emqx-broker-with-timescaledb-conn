#!/bin/bash
# set -ex

## Get the OS
OS_TYPE=$(uname)

create_user() {
    curl -X POST http://localhost:18083/api/v5/authentication/password_based:built_in_database/users \
        -u ${EMQX_API_KEY}:${EMQX_SECRET_KEY} \
        -H "Content-Type: application/json" \
        -d '{
            "user_id": "'${EMQX_DEVELOPER_USERNAME}'",
            "password": "'${EMQX_DEVELOPER_PASSWORD}'",
            "is_superuser": true
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
    echo "${OS_TYPE} detected. Creating the ${EMQX_DEVELOPER_USERNAME} developer user..."
    # Verify the OS
    case "${OS_TYPE}" in
        "Darwin")
            set_up_env_variable_file
            source ../settings.env
            create_user
            ;;
        "Linux")
            set_up_env_variable_file
            source ../settings.env
            create_user
            ;;
        *)
            echo "System isn't supported by this script: ${OS_TYPE}"
            echo "Please contact to the support team."
            exit 1
            ;;
    esac

    echo "User '${EMQX_DEVELOPER_USERNAME}' to Postgresql created..."
}

main