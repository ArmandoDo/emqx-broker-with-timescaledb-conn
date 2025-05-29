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

-- Set the chunk time interval to 30 days
SELECT set_chunk_time_interval('units_status', INTERVAL '30 days');

-- Set the compression policy for the units_status table
ALTER TABLE units_status SET (
  timescaledb.compress,
  timescaledb.compress_orderby = 'time DESC',
  timescaledb.compress_segmentby = 'dispenser_id'
);

-- Enable compression for the units_status table
SELECT add_compression_policy('units_status', INTERVAL '60 days');

-- Set the retention policy for the units_status table
-- Retention policy will automatically drop chunks older than 120 days
SELECT add_retention_policy('units_status', INTERVAL '120 days');

SELECT alter_job(
  job_id := (
    SELECT job_id FROM timescaledb_information.jobs 
    WHERE hypertable_name = 'units_status' AND proc_name = 'policy_compression'
  ),
  schedule_interval := INTERVAL '1 day'
);

SELECT alter_job(
  job_id := (
    SELECT job_id FROM timescaledb_information.jobs 
    WHERE hypertable_name = 'units_status' AND proc_name = 'policy_retention'
  ),
  schedule_interval := INTERVAL '1 day'
);


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


-- Set the chunk time interval to 30 days
SELECT set_chunk_time_interval('emqx_client_events', INTERVAL '30 days');

-- Set the compression policy for the emqx_client_events table
ALTER TABLE emqx_client_events SET (
  timescaledb.compress,
  timescaledb.compress_orderby = 'time DESC',
  timescaledb.compress_segmentby = 'event'
);

-- Enable compression for the emqx_client_events table
SELECT add_compression_policy('emqx_client_events', INTERVAL '60 days');

-- Set the retention policy for the emqx_client_events table
-- Retention policy will automatically drop chunks older than 120 days
SELECT add_retention_policy('emqx_client_events', INTERVAL '120 days');

SELECT alter_job(
  job_id := (
    SELECT job_id FROM timescaledb_information.jobs 
    WHERE hypertable_name = 'emqx_client_events' AND proc_name = 'policy_compression'
  ),
  schedule_interval := INTERVAL '1 day'
);

SELECT alter_job(
  job_id := (
    SELECT job_id FROM timescaledb_information.jobs 
    WHERE hypertable_name = 'emqx_client_events' AND proc_name = 'policy_retention'
  ),
  schedule_interval := INTERVAL '1 day'
);

-- Grant permissions to the admin user
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE units_status TO $POSTGRES_ADMIN_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE emqx_client_events TO $POSTGRES_ADMIN_USER;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO $POSTGRES_ADMIN_USER;

EOSQL