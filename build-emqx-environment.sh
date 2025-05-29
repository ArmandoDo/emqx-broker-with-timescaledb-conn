#!/bin/bash

# Build PostgreSQL with TimescaleDB on Docker
./installation-scripts/build-pg-with-timescaledb.sh || exit 1

# Build EMQX broker on Docker
./installation-scripts/build-emqx-boker.sh || exit 1
