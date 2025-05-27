#!/bin/bash
# set -ex

# Wait until postgres is ready
until pg_isready -U postgres; do
  sleep 1
done

# Create new users
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL

-- Create sensor data table
CREATE TABLE units_status (
  time              TIMESTAMPTZ      NOT NULL,
  topic             TEXT             NOT NULL,
  qos               SMALLINT,
  retain            BOOLEAN,
  dup               BOOLEAN,
  dispenser_id      TEXT             NOT NULL,
  session_id        TEXT,
  energy_kwh        DOUBLE PRECISION,
  voltage_v         DOUBLE PRECISION,
  current_a         DOUBLE PRECISION,
  temperature_c     DOUBLE PRECISION,
  status            TEXT,
  station_id        TEXT
);

-- Create time-based partitioning policy
-- Partitioning the data into four equally sized time ranges allows 
-- for easier querying within specific time ranges and provides improved performance and scalability as the data grows.
SELECT create_hypertable('units_status', 'time');


-- Create the event table to register the client events
CREATE TABLE emqx_client_events (
  time        TIMESTAMPTZ     NOT NULL DEFAULT now(),
  clientid    TEXT,
  event       TEXT
);


-- Create time-based partitioning policy
-- Partitioning the data into four equally sized time ranges allows 
-- for easier querying within specific time ranges and provides improved performance and scalability as the data grows.
SELECT create_hypertable('emqx_client_events', 'time');


-- Grant permissions to the admin user
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE units_status TO $POSTGRES_ADMIN_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE emqx_client_events TO $POSTGRES_ADMIN_USER;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO $POSTGRES_ADMIN_USER;

EOSQL