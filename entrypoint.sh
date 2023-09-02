#!/bin/sh
sleep 2 # just to make sure postgres is up
cd /app
echo "run db:reset"
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bin/rails db:reset
echo "run Puma"
bin/bundle exec puma -C config/puma.rb
