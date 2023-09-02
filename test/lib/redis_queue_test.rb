require 'test_helper'
require 'mock_redis'

class RedisQueueTest < ActiveSupport::TestCase
  setup do
    @queue = RedisQueue.new(MockRedis.new)
    @key = 'foo'

    @queue.push(@key, { a: 'foo'})
    @queue.push(@key, { a: 'bar'})
    @queue.push(@key, { a: 'hello'})
    @queue.push(@key, { a: 'world'})
  end

  test 'should push new item and set timestamp and counter' do
    assert Time.now > @queue.last_timestamp(@key)
    assert_equal 4, @queue.size(@key)
  end

  test 'should check if list is being correctly appended' do
    values = @queue.fetch_batch(@key, 3).map { |item| item['a'] }
    assert_equal ['foo', 'bar', 'hello'], values

    values = @queue.fetch_batch(@key, 3).map { |item| item['a'] }
    assert_equal ['world'], values
  end

  test 'should have correct counter' do
    assert_equal 4, @queue.counter(@key)
  end
end
