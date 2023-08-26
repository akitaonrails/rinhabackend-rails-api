#!/bin/sh
sleep 2 # just to make sure postgres is up
cd /app
echo "run db:create"
bin/rails db:create
echo "run db:migrate"
bin/rails db:migrate
echo "run Puma"
bin/bundle exec puma -C config/puma.rb
