require 'rails'

module Cachet
  mattr_accessor :logger
  mattr_accessor :storage
  mattr_accessor :enabled

  class << self
    def setup
      yield self
    end

    def cache (entity, key)
      if enabled
        cached_item = storage.read(entity, key)
        if not cached_item
          cached_item = yield
          storage.write(entity, key, cached_item)
          Cachet.logger.info "#{entity} with key:#{key} could not found in cache. Evaluated and written to cache"
        else
          Cachet.logger.info "#{entity} with key:#{key} found in cache."
        end
        cached_item
      else
        yield
      end
    end

    def invalidate (entity, key)
      if enabled
        storage.purge(entity, key)
        Cachet.logger.info "#{entity} with key:#{key} invalidated."
      end
    end
  end
end

require 'cachet/file_store'
require 'cachet/cacheable'


