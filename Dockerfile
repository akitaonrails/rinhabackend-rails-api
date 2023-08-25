# Use an official Ruby runtime as a parent image
FROM docker.io/ruby:3.2

# Set the working directory in the container to /app
WORKDIR /app

# Set environment variables
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Install nodejs and yarn
RUN apt-get update -qq && apt-get install -y nodejs npm && npm install -g yarn

# Install PostgreSQL client
RUN apt-get install -y postgresql-client

# Copy Gemfile and Gemfile.lock for bundle install
COPY Gemfile* ./

# Install gems
RUN bundle install --without development test --jobs 4 --retry 3

# Copy the current directory contents into the container at /app
COPY . .

# Precompile Rails assets
#RUN bin/rails assets:precompile

# Expose port 3000 to the Docker host, so you can access it from the outside.
EXPOSE 3000

# Start the main process
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-u", "puma"]