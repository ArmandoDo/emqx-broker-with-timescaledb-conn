#!/bin/bash

# Build PostgreSQL with TimescaleDB on Docker
./installation-scripts/build-pg-with-timescaledb.sh

# Build EMQX broker on Docker
./installation-scripts/build-emqx-boker.sh

# Build the simulator for MQTTX CLI
./installation-scripts/build-mqttx-cli.sh