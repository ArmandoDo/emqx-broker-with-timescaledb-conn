FROM timescale/timescaledb-ha:pg15.13-ts2.20.0

### Set up the Postgresql TmescaleDB image
USER postgres

# Scripts for the DB initialization
COPY postgresql-timescaledb/scripts/create-users.sh /docker-entrypoint-initdb.d/100-create-users.sh
COPY postgresql-timescaledb/scripts/create-emqx-tables.sh /docker-entrypoint-initdb.d/101-create-emqx-tables.sh