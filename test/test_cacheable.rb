require_relative 'test_helper'

module Cachet
  mattr_accessor :cache_calls
  mattr_accessor :invalidate_calls

  def self.cache (entity, key)
    @@cache_calls = ((@@cache_calls or []) << [entity, key])
  end

  def self.invalidate (entity, key)
    @@invalidate_calls = ((@@invalidate_calls or []) << [entity, key])
  end
end

class CacheableTest < Test::Unit::TestCase
  include Cachet::Cacheable

  def setup
  end

  def method_cached(param1, param2)
    return [param1, param2].join('-')
  end

  def method_invalidator(param1, param2)

  end

  def test_cacheable
    self.method_cached 'umut', 'utkan'
    assert_equal Cachet.cache_calls.length, 1
    cache_call = Cachet.cache_calls[0]
    assert_equal :foo, cache_call[0]
    assert_equal 'umut-utkan', cache_call[1]

    self.method_invalidator 'umut', 'utkan'
    assert_equal Cachet.invalidate_calls.length, 2
    invalidate_call = Cachet.invalidate_calls[0]
    assert_equal :foo, invalidate_call[0]
    assert_equal 'umut/utkan', invalidate_call[1]
    invalidate_call = Cachet.invalidate_calls[1]
    assert_equal :bar, invalidate_call[0]
    assert_equal 'umut/utkan', invalidate_call[1]
  end

  cacheable :method_cached, :foo do |param1, param2|
    [param1, param2].join '-'
  end

  cache_invalidator :method_invalidator, [:foo, :bar] do |param1, param2|
    [param1, param2].join '/'
  end

end