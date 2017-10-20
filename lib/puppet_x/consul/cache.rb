require 'digest/md5'
require 'fileutils'
require 'json'

module PuppetX
  module Consul
    class CacheError < StandardError
    end

    # Manages an file based cache to allow data to be cached
    # accross puppet runs and restarts.
    #
    # The data is cached in a specified directory.
    # The cache is indefinite and only used when consul is un-available.
    #
    # If the data in the cache needs to be updated is determined by using
    # a key and the idx.
    #
    # Some of the basic assumptions / rules.
    # - Key + idx is enough to determine if we allready hold this data.
    #   We are using the modifyIndex for this, but something representative
    #   of the version of the data would be enough.  A hash f.e.
    # - Key + idx are represented in the filename, no need to read the file
    #   to determine if the cache is up-to-date.
    # - Data for different Keys are stored in the different files.
    # - If multiple threads try to update the same key, only one succeeds.
    #    The rest aborts the update and can try again next time if needed.
    # - Only one version of the data is kept.
    # - We maintain both a global in-memory cache and file cache.
    #   They are considered to be insync unless the process restarted.
    #   Consistency is recovered when data is fetched from the cache.
    class Cache
      def initialize(directory)
        FileSystemCache.directory(directory)
      end

      def store_cache(key, idx, data)
        idx = idx.to_s
        # The data on disk is allready up-to-date
        return if key_exists(key, idx)

        FileSystemCache.put_key_idx(key, idx, data)
        InMemoryCache.put_key_idx(key, idx, data)
      end

      # key_exists tests if the data is allready cached
      # returns true if so.
      def key_exists(key, idx)
        idx = idx.to_s

        return true if InMemoryCache.knows_key_idx(key, idx)
        FileSystemCache.knows_key_idx(key, idx)
      end

      # Retrieve the data from the cache.
      # If multiple files exist for the key, take the
      def retrieve_cache(key)
        # Find the best cache file for this key, delete the rest.

        data = InMemoryCache.get_data(key)
        return data unless data.nil?

        data = FileSystemCache.get_data(key)
        return nil if data.nil?

        # repopulate the in memory database.
        idx = FileSystemCache.get_last_idx(key)
        InMemoryCache.put_key_idx(key, idx, data)

        data
      end

      def self.clear
        InMemoryCache.clear
      end
    end

    class InMemoryCache
      # protects known_cache_objects
      @@semaphore = Mutex.new
      # Keeps track of what we allready cached.
      # This mainly keeps the file system calls low.
      @@known_cache_objects = {}
      @@known_cache_object_data = {}

      def self.put_key_idx(key, idx, data)
        @@semaphore.synchronize do
          @@known_cache_objects[key] = idx
          @@known_cache_object_data[key] = data
        end
      end

      def self.knows_key_idx(key, idx)
        @@semaphore.synchronize do
          known_idx = @@known_cache_objects.fetch(key, 0)
          return true if idx == known_idx
        end
        false
      end

      def self.get_data(key)
        @@semaphore.synchronize do
          known_idx = @@known_cache_objects.fetch(key, 0)
          return @@known_cache_object_data[key] if known_idx != 0
        end
        nil
      end

      def self.clear
        @@semaphore.synchronize do
          @@known_cache_objects = {}
          @@known_cache_object_data = {}
        end
      end
    end

    class FileSystemCache
      def self.directory(directory)
        @@directory = directory
        return if directory.nil?

        FileUtils.mkdir_p directory unless File.directory?(directory)
      end

      def self.put_key_idx(key, idx, data)
        return if @@directory.nil?

        # Only continue if we can grab the lock.
        # multiple threads will be attempting to
        # update the same key with fresh data.
        # only one needs to win for all to benefit.
        lock_for_update(key) do
          cache_file_name = fetch_cache_file_name(key, idx)

          raise CacheError, "cache file allready exists: #{cache_file_name}. This probably a race condition." if File.file?(cache_file_name)
          File.open(cache_file_name, 'w') { |file| file.write(data.to_json) }

          # Clean up old versions of the data. Keep only the latest.
          delete_old_cache(key, idx)
        end
      end

      def self.knows_key_idx(key, idx)
        return if @@directory.nil?

        cache_file_name = fetch_cache_file_name(key, idx)
        File.file?(cache_file_name)
      end

      def self.get_data(key)
        return if @@directory.nil?

        filename = fetch_last_cache_file_and_delete_rest(key)
        return nil if filename.nil?
        JSON.parse(File.read(filename))
      end

      def self.get_last_idx(key)
        return if @@directory.nil?

        # See what cache files exist
        md5 = key_hash(key)
        list_of_cache_files = Dir.glob("#{@@directory}/#{md5}-*.cache")
        if list_of_cache_files.length == 1
          return get_idx_from_file_name(list_of_cache_files[0])
        end

        # there are multiple possibilities, find the latest and delete the rest.
        newest_file = find_newest_file(list_of_cache_files)

        list_of_cache_files.delete_if { |name| name == newest_file }
        FileUtils.rm(list_of_cache_files)
        newest_file
      end

      private_class_method

      def self.find_newest_file(_files)
        max_ctime = Time.at(0)
        newest_file = ''
        list_of_cache_files.each do |filename|
          ctime = File.ctime(filename)
          if max_ctime < ctime
            max_ctime = ctime
            newest_file = filename
          end
        end
      end

      def self.get_idx_from_file_name(filename)
        m = /-([^-]+).cache$/.match(filename)
        m[0]
      end

      def self.fetch_cache_file_name(key, idx)
        md5 = key_hash(key)
        "#{@@directory}/#{md5}-#{idx}.cache"
      end

      def self.key_hash(key)
        Digest::MD5.hexdigest(key.to_s).to_s
      end

      def self.delete_old_cache(key, idx)
        md5 = key_hash(key)
        list_of_cache_files = Dir.glob("#{@@directory}/#{md5}-*.cache")
        list_of_cache_files.delete_if { |name| name.end_with?("#{idx}.cache") }
        FileUtils.rm(list_of_cache_files)
      end

      # lock_for_update creates a mutually exclusive lock
      # ensuring that this thread/process is only one updating the file.
      def self.lock_for_update(key)
        md5 = key_hash(key)
        lock_file_name = "#{@@directory}/#{md5}.lock"

        open(lock_file_name, 'w') do |lock_file|
          success = lock_file.flock(File::LOCK_EX | File::LOCK_NB)
          if success
            begin
              yield
            ensure
              lock_file.flock(File::LOCK_UN)
            end
          end
        end
      end

      def self.fetch_last_cache_file_and_delete_rest(key)
        # See what cache files exist
        md5 = key_hash(key)
        list_of_cache_files = Dir.glob("#{@@directory}/#{md5}-*.cache")
        return nil if list_of_cache_files.length.zero?
        return list_of_cache_files[0] if list_of_cache_files.length == 1

        # there are multiple possibilities, find the latest and delete the rest.
        max_ctime = Time.at(0)
        newest_file = ''
        list_of_cache_files.each do |filename|
          ctime = File.ctime(filename)
          if max_ctime < ctime
            max_ctime = ctime
            newest_file = filename
          end
        end
        list_of_cache_files.delete_if { |name| name == newest_file }
        FileUtils.rm(list_of_cache_files)
        newest_file
      end
    end
  end
end
