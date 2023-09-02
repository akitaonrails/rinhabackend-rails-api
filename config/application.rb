require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"  # Uncomment for ActiveRecord
# require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
# require "action_mailer/railtie"  # Comment out for ActionMailer
# require "action_mailbox/engine"  # Comment out for ActionMailbox
# require "action_text/engine"     # Comment out for ActionText
# require "action_cable/engine"    # Comment out for ActionCable
# require "sprockets/railtie"
# require "rails/test_unit/railtie" # Comment out for TestUnit

require './lib/tag_coder'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rinhabackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.active_record.schema_format = :sql
  end
end
