#!/bin/sh
sleep 2 # just to make sure postgres is up
echo "run db:reset"
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bin/rails db:reset
echo "run Puma"
bundle exec puma -C config/puma.rb
