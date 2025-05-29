#!/bin/bash

# Build PostgreSQL with TimescaleDB
./installation-scripts/install-pg-with-timescaledb.sh || exit 1

# Intall EMQX broker
./installation-scripts/install-emqx-broker.sh || exit 1


