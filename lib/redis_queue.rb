require 'redis'
require 'connection_pool'
require 'mock_redis' unless Rails.env.production?

# Redis based Queue to register params for the inserts
# when there's enough items we can fetch_batch to perform an insert_all
class RedisQueue
  def initialize(conn = nil)
    conn ||= Redis.new(uri: "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}:6379/10")
    @redis_pool = ConnectionPool.new(
      size: ENV.fetch('REDIS_POOL_SIZE', '5').to_i,
      timeout: ENV.fetch('REDIS_TIMEOUT', '5').to_i) do
      conn
    end
  end

  def push(queue, value)
    return if queue.nil? || value.nil?

    @redis_pool.with do |conn|
      conn.rpush(queue, value.to_json)
      conn.set("#{queue}-timestamp", Time.now.to_json)
      conn.incr("#{queue}-counter")
    end
  end

  def last_timestamp(queue)
    return nil unless queue

    @redis_pool.with do |conn|
      timestamp = JSON.parse(conn.get("#{queue}-timestamp") || 'null')
      timestamp ? Time.parse(timestamp) : nil
    end
  end

  def size(queue)
    return -1 unless queue

    @redis_pool.with do |conn|
      conn.llen(queue)
    end
  end

  def fetch_batch(queue, batch_size = 10)
    @redis_pool.with do |conn|
      buffer_size = conn.llen(queue)
      end_index = [batch_size - 1, buffer_size - 1].min
      items = conn.lrange(queue, 0, end_index).map { |item| JSON.parse(item || 'null') }
      conn.ltrim(queue, end_index + 1, -1)
      items
    end
  end

  def clear!(queue)
    @redis_pool.with do |conn|
      conn.del("#{queue}-timestamp")
      conn.del("#{queue}-counter")
      conn.del(queue)
    end
  end

  def counter(queue)
    return 0 unless queue

    @redis_pool.with do |conn|
      conn.get("#{queue}-counter").to_i
    end
  end
end

REDIS_QUEUE = RedisQueue.new(Rails.env.production? ? nil : MockRedis.new)
