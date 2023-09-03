require 'test_helper'
require 'mock_redis'

class RedisQueueTest < ActiveSupport::TestCase
  setup do
    @key = 'foo'
    REDIS_QUEUE.clear!(@key)

    REDIS_QUEUE.push(@key, { a: 'foo' })
    REDIS_QUEUE.push(@key, { a: 'bar' })
    REDIS_QUEUE.push(@key, { a: 'hello' })
    REDIS_QUEUE.push(@key, { a: 'world' })
  end

  test 'should push new item and set timestamp and counter' do
    assert_equal 4, REDIS_QUEUE.size(@key)
  end

  test 'should check if list is being correctly appended' do
    values = REDIS_QUEUE.fetch_batch(@key, 3).map { |item| item['a'] }
    assert_equal ['foo', 'bar', 'hello'], values

    values = REDIS_QUEUE.fetch_batch(@key, 3).map { |item| item['a'] }
    assert_equal ['world'], values
  end

  test 'should have correct counter' do
    assert_equal 4, REDIS_QUEUE.counter(@key)
  end
end
