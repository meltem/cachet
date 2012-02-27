require 'digest/md5'

module Cachet
  class FileStore
    attr_reader :root
    attr_accessor :optimize
    attr_accessor :dir_level
    attr_accessor :dir_count

    def initialize(root)
      @root = root
      FileUtils.mkdir_p root
      @optimize = TRUE
      @dir_level = 3
      @dir_count = 19
    end

    def read(entity, key)
      file_name = storage_path(entity, key)
      File.open(file_name, 'rb') { |f| Marshal.load f.read } if  File.exist?(file_name)
    end

    def write(entity, key, data_to_be_stored)
      file_name = storage_path(entity, key)
      temp_file_name = file_name + '.' + Thread.current.object_id.to_s
      FileUtils.mkdir_p File.dirname(file_name)
      File.open(temp_file_name, 'wb') { |f| f.write(Marshal.dump(data_to_be_stored)) }
      if File.exist?(file_name)
        File.unlink temp_file_name
      else
        FileUtils.mv temp_file_name, file_name
      end
      Cachet.logger.info "A new #{entity} entity stored in the cache with key:#{key} to path #{file_name}."
    end

    def purge(entity, key)
      file_name = storage_path(entity, key)
      begin
        File.unlink file_name if  File.exist?(file_name)
      rescue
        Cachet.logger.warn "An element of #{entity} in the cache with key:#{key} to path #{file_name}entity has could not be deleted."
      end
      Cachet.logger.info "An element of #{entity} in the cache with key:#{key} to path #{file_name}entity has been removed from the cache."
    end

    def entities
      Dir.entries(root).reject { |entry| entry =='.' || entry == '..' }.inject({}) do |entities, entity|
        entities[entity] = Dir["#{root}/#{entity}/**/*"].count { |file| File.file?(file) }
        entities
      end
    end

    def remove_entity(entity)
      FileUtils.remove_dir File.join root, entity
    end

    def storage_path(entity, key)
      file_name = Digest::MD5.hexdigest(key)
      if optimize
        dirs = (1..dir_level).inject({:hash=>key.sum, :dirs=>[]}) do |result, level|
          result[:dirs] << (result[:hash] % dir_count).abs.to_s
          result[:hash] += (result[:hash] * 31)
          result
        end
        file_name = File.join dirs[:dirs], file_name
      end
      File.join root, entity.to_s, file_name
    end
  end
end
