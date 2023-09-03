require 'redis'
require 'connection_pool'
require 'mock_redis' unless Rails.env.production?

# Redis based Queue to register params for the inserts
# when there's enough items we can fetch_batch to perform an insert_all
class RedisQueue
  REDIS_URL = 'redis://%s:6379/5'.freeze

  def initialize(queue)
    @queue = queue
    @key_counter = "#{queue}-counter"
    @redis_pool = ConnectionPool.new(
      size: ENV.fetch('REDIS_POOL_SIZE', '5').to_i,
      timeout: ENV.fetch('REDIS_TIMEOUT', '5').to_i
    ) do
      Rails.env.production? ? Redis.new(uri: redis_uri) : MockRedis.new
    end
  end

  def push(value)
    return if @queue.nil? || value.nil?

    @redis_pool.with do |conn|
      conn.rpush(@queue, value.to_json)
      conn.incr(@key_counter)
    end
  end

  def size
    return -1 unless @queue

    @redis_pool.with do |conn|
      conn.llen(@queue)
    end
  end

  def fetch_batch(batch_size = 10)
    @redis_pool.with do |conn|
      buffer_size = conn.llen(@queue)
      end_index = [batch_size - 1, buffer_size - 1].min
      items = conn.lrange(@queue, 0, end_index).map { |item| JSON.parse(item || 'null') }
      conn.ltrim(@queue, end_index + 1, -1)
      items
    end
  end

  def clear!
    @redis_pool.with do |conn|
      conn.del(@key_counter)
      conn.del(@queue)
    end
  end

  def counter
    return 0 unless @queue

    @redis_pool.with do |conn|
      conn.get(@key_counter).to_i.tap do |value|
        Rails.cache.write(@key_counter, value)
      end
    end
  end

  private

  def redis_uri
    @redis_uri ||= REDIS_URL.format(ENV.fetch('REDIS_HOST', 'localhost'))
  end
end
