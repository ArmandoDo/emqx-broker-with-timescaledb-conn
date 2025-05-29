#!/bin/bash

## This script install the dockerize version of EMQX broker in your
## local environment. Run the build script before start the installation
##
## Usage:
## ./install-emqx-broker.sh
# set -ex

## Get the OS
OS_TYPE=$(uname)

## Install docker image on linux
install_emqx_broker() {
    # Load container registry variables
    source settings.env
    # Load env file
    set_up_env_variable_file
    stop_containers
    # Run EMQX container from docker compose
    ${DOCKER_COMPOSE_COMMAND} --file docker/${DOCKER_COMPOSE_FILE} up \
        --detach ${EMQX_CONTAINER_NAME}
    # Run MQTTX webui container from docker compose
    ${DOCKER_COMPOSE_COMMAND} --file docker/${DOCKER_COMPOSE_FILE} up \
        --detach mqttx-webui
}


# Set up the docker compose command available on the server
set_up_docker_compose_command() {
    if command -v docker-compose &> /dev/null; then
        export DOCKER_COMPOSE_COMMAND="docker-compose"
    elif command -v docker compose &> /dev/null; then
        export DOCKER_COMPOSE_COMMAND="docker compose"
    else
        echo "Docker Compose is not installed or started in your system.
        Please install the service."
        echo "Exiting..."

        exit 1
    fi
}

# Set up the environment variable file .env
set_up_env_variable_file() {
    if ! source .env; then
        echo "Missing .env file with the environment variables. Please create the .env file"
        exit 1
    fi
}

## Stop docker container
stop_containers() {
    # Stop and remove the EMQX broker container
    ${DOCKER_COMPOSE_COMMAND} --file docker/${DOCKER_COMPOSE_FILE} stop \
        ${EMQX_CONTAINER_NAME}
    ${DOCKER_COMPOSE_COMMAND} --file docker/${DOCKER_COMPOSE_FILE} rm \
        --force ${EMQX_CONTAINER_NAME}

    # Stop and remove the MQTTX webui container
    ${DOCKER_COMPOSE_COMMAND} --file docker/${DOCKER_COMPOSE_FILE} stop mqttx-webui
    ${DOCKER_COMPOSE_COMMAND} --file docker/${DOCKER_COMPOSE_FILE} rm --force mqttx-webui

}

# Verify if the Docker engine is installed on the system
verify_docker_engine() {
    # Verify if service is installed
    if ! command -v docker &> /dev/null; then
        echo "Docker Engine is not installed in your system. Please install the service..."
        echo "Exiting..."
        exit 1
    fi

    # Verify if service is running
    if ! docker info &> /dev/null; then
        echo "Docker engine is installed, but not started. Please launch the service..."
        echo "Exiting..."
        exit 1
    fi
}

## Main function
main() {
    echo "${OS_TYPE} detected. Starting the installation..."
    # Verify the OS
    case "${OS_TYPE}" in
        "Darwin")
            export DOCKER_COMPOSE_FILE="docker-compose.darwin.yaml"
            verify_docker_engine
            set_up_docker_compose_command
            install_emqx_broker
            ;;
        "Linux")
            export DOCKER_COMPOSE_FILE="docker-compose.ubuntu.yaml"
            verify_docker_engine
            set_up_docker_compose_command
            install_emqx_broker
            ;;
        *)
            echo "System isn't supported by this script: ${OS_TYPE}"
            echo "Please contact to the support team."
            exit 1
            ;;
    esac

    echo "${EMQX_CONTAINER_NAME} docker image deployed on host..."
}

main