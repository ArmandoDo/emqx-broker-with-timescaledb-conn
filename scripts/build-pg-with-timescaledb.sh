#!/bin/bash

## This script builds the dockerize version of Postgresql 15.13 with
## TimescaleDB 2.20.0 extension. The script is designed to run on MacOS
## and Linux in your local environment. Modify the config files if
## it's necessary
## 
## Usage:
## ./build-pg-with-timescaledb.sh
# set -ex

## Get the OS
OS_TYPE=$(uname)

## Build docker image on Darwin (MacOS)
containerize_on_darwin() {
    # Load container registry variables
    source settings.env

    echo "Building ${POSTGRES_CONTAINER_NAME} image in" \
    "'${REGISTRY_NAME}/${POSTGRES_CONTAINER_NAME}:${POSTGRES_CONTAINER_TAG}'"

    docker build --rm --no-cache \
        -t ${REGISTRY_NAME}/${POSTGRES_CONTAINER_NAME}:${POSTGRES_CONTAINER_TAG} \
        -f ./docker/postgresql-timescaledb/Dockerfile . || exit 1

    # Delete none images generated in the build process
    delete_none_images

    echo "Docker image building has completed successfully in" \
    "'${REGISTRY_NAME}/${POSTGRES_CONTAINER_NAME}:${POSTGRES_CONTAINER_TAG}'"
}

## Build docker image on Ubuntu Linux
containerize_on_linux() {
    # Load container registry variables
    source settings.env

    echo "Building ${POSTGRES_CONTAINER_NAME} image in" \
    "'${REGISTRY_NAME}/${POSTGRES_CONTAINER_NAME}:${POSTGRES_CONTAINER_TAG}'"

    docker build --rm --no-cache --progress=plain \
        -t ${REGISTRY_NAME}/${POSTGRES_CONTAINER_NAME}:${POSTGRES_CONTAINER_TAG} \
        -f ./docker/postgresql-timescaledb/Dockerfile . || exit 1

    # Delete none images generated in the build process
    delete_none_images
    
    echo "Docker image building has completed successfully in" \
    "'${REGISTRY_NAME}/${POSTGRES_CONTAINER_NAME}:${POSTGRES_CONTAINER_TAG}'"
}

# Delete none images on container repository
delete_none_images() {
    docker images --filter "dangling=true" -q | xargs -r docker rmi
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
main(){
    echo "${OS_TYPE} OS detected. Starting the installation..."
    # Verify the OS
    case "${OS_TYPE}" in
        "Darwin")
            verify_docker_engine
            containerize_on_darwin
            ;;
        "Linux")
            verify_docker_engine
            containerize_on_linux
            ;;
        *)
            echo "System isn't supported by this script: ${OS_TYPE}"
            echo "Please contact to the support team."
            exit 1
            ;;
    esac
}

main