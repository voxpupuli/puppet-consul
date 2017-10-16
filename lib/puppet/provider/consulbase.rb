require 'json'
require 'net/http'
require 'uri'

class Puppet::Provider::ConsulBase < Puppet::Provider
  def self.prefetch(resources)
    resources.each do |name, resource|
      Puppet.debug("prefetching for #{name}")

      found_prepared_queries = list_resources(resource).select do |prepared_query|
        prepared_query[:name] == name
      end

      found_prepared_query = found_prepared_queries.first || nil
      if found_prepared_query
        Puppet.debug("found #{found_prepared_query}")
        resource.provider = new(found_prepared_query)
      else
        Puppet.debug("found none #{name}")
        resource.provider = new(:ensure => :absent)
      end
    end
  end

  # responsible for caching the retrieved resources.
  # calls fetch_resources for the actual fetching.
  def self.list_resources(opts = {})
    cache_key = get_cache_key(opts)
    return @cached_resources[cache_key] if @cached_resources[cache_key]

    remote_resources = fetch_resources(opts)
    @cached_resources[cache_key] = remote_resources
    remote_resources
  end

  # resets the cache. Usefull during testing
  def self.reset
    @cached_resources = {}
  end

  def get_current_resource
    name = @resource[:name]
    resources = self.class.list_resources(@resource).select do |res|
      res[:name] == name
    end
    # if the user creates multiple with the same name this will do odd things
    resources.first || nil
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    remote_resource = get_current_resource

    if @property_flush[:ensure] == :absent
      # delete consul resource if it exists
      delete_remote_resource(remote_resource) if remote_resource
    elsif @property_flush[:ensure] == :present
      if remote_resource
        if remote_requires_update?(remote_resource)
          # Remote exists and requires update
          update_remote_resource(remote_resource)
        end
      else
        create_remote_resource
      end
    end

    @property_hash.clear
  end
end
