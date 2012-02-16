require 'rails'

module Cachet
  mattr_accessor :logger
  mattr_accessor :storage

  class << self
    def setup
      yield self
    end

    def cache (entity, key)
      cached_item = storage.read(entity, key)
      if not cached_item
        cached_item = yield
        storage.write(entity, key, cached_item)
        Cachet.logger.info "#{entity} with key:#{key} could not found in cache. Evaluated and written to cache"
      else
        Cachet.logger.info "#{entity} with key:#{key} found in cache."
      end
      cached_item
    end

    def invalidate (entity, key)
      storage.purge(entity, key)
      Cachet.logger.info "#{entity} with key:#{key} invalidated."
    end
  end

end

require 'cachet/file_store'
require 'cachet/cacheable'


