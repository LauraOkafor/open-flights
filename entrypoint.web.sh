#!/bin/bash
# set -e

# # Remove a potentially pre-existing server.pid for Rails.
# rm -f /app/tmp/pids/server.pid

# # Wait for database to be ready
# until PGPASSWORD=$DATABASE_PASSWORD psql -h $DATABASE_HOST -U $DATABASE_USERNAME -d $POSTGRES_DB -c '\q' 2>/dev/null; do
#   >&2 echo "Postgres is unavailable - sleeping"
#   sleep 1
# done

# # Start the Rails server
# exec "$@"


set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready
until PGPASSWORD=$DATABASE_PASSWORD psql -h $DATABASE_HOST -U $DATABASE_USERNAME -d postgres -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"

# Drop and recreate the database
PGPASSWORD=$DATABASE_PASSWORD psql -h $DATABASE_HOST -U $DATABASE_USERNAME -d postgres -c 'DROP DATABASE IF EXISTS "open-flights"'
PGPASSWORD=$DATABASE_PASSWORD psql -h $DATABASE_HOST -U $DATABASE_USERNAME -d postgres -c 'CREATE DATABASE "open-flights"'

# Run database setup commands
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

# Start the Rails server
exec "$@"
