module Cachet
  module Cacheable
    def self.included(base)
      Cachet.logger.debug "Including Cacheable in #{base}"
      base.extend ClassMethods
    end

    module ClassMethods
      def cacheable (cached_method, entity)
        define_method("#{cached_method}_with_cache") { |*args|
          cache_key = block_given? ? yield(*args) : cached_method.to_s
          Cachet.cache(entity, cache_key) do
            method("#{cached_method}_without_cache".to_sym).call(*args)
          end
        }
        alias_method_chain "#{cached_method}".to_sym, :cache
        Cachet.logger.debug "Aliasing method : #{cached_method} to cache the result as #{entity} entities"
      end

      def cache_invalidator (cached_method, entity)
        define_method("#{cached_method}_with_cache_invalidation") { |*args|
          cache_key = block_given? ? yield(*args) : cached_method.to_s
          method("#{cached_method}_without_cache_invalidation".to_sym).call(*args)
          (entity.kind_of?(Array) ? entity : [entity]).each do |ent|
            Cachet.invalidate(ent, cache_key)
          end
        }
        alias_method_chain "#{cached_method}".to_sym, :cache_invalidation
        Cachet.logger.debug "Aliasing method : #{cached_method} to invalidate the #{entity} entities"
      end
    end
  end
end
