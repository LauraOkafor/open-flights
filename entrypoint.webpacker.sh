#!/bin/bash
# set -e

# # Remove a potentially pre-existing server.pid for Rails.
# rm -f /app/tmp/pids/server.pid

# # Start the webpack dev server
# exec "$@"

set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
  echo "Installing node dependencies..."
  yarn install
fi

# Verify webpack configuration
if [ ! -f "config/webpack/development.js" ]; then
  echo "Webpack configuration not found!"
  exit 1
fi

# Compile webpack if needed
if [ "$RAILS_ENV" = "production" ]; then
  echo "Compiling webpack assets..."
  ./bin/webpack
fi

# Start the webpack dev server
echo "Starting webpack-dev-server..."
exec "$@"
