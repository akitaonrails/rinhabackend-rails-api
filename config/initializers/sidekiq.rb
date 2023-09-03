Sidekiq.configure_server do |config|
  # config.logger = nil
  config.redis = { url: "redis://#{ENV['REDIS_HOST'] || "localhost"}:6379/0"}
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV['REDIS_HOST'] || "localhost"}:6379/0"}
end

Sidekiq.strict_args!(false)
