require 'test_helper'
require 'mock_redis'

class RedisQueueTest < ActiveSupport::TestCase
  setup do
    @queue = RedisQueue.new("test")

    @queue.push({ a: 'foo' })
    @queue.push({ a: 'bar' })
    @queue.push({ a: 'hello' })
    @queue.push({ a: 'world' })
  end

  test 'should push new item and set timestamp and counter' do
    assert_equal 4, @queue.size()
  end

  test 'should check if list is being correctly appended' do
    values = @queue.fetch_batch(3).map { |item| item['a'] }
    assert_equal ['foo', 'bar', 'hello'], values

    values = @queue.fetch_batch(3).map { |item| item['a'] }
    assert_equal ['world'], values
  end

  test 'should have correct counter' do
    assert_equal 4, @queue.counter()
  end
end
