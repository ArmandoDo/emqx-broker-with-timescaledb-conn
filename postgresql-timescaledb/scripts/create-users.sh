#!/bin/bash
# set -ex

# Wait until postgres is ready
until pg_isready -U postgres; do
  sleep 1
done

# Create new users
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER $POSTGRES_ADMIN_USER WITH ENCRYPTED PASSWORD '$POSTGRES_ADMIN_PASSWORD';
  GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_ADMIN_USER;
EOSQL