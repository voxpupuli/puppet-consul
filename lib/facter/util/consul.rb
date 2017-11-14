module Facter::Util::Consul
  require 'json'
  require 'net/http'
  require 'uri'

  CONSUL_URL = 'http://localhost:8500/v1'

  def self.get_request(api_end_point)
    res = Net::HTTP.get_response(URI.parse("#{CONSUL_URL}#{api_end_point}"))
    # for key request we could get a 404 response for invalid keys
    if res.response.code == '404'
      return nil if (api_end_point =~ /\/kv\//) != nil
    end
    if res.response.code != "200"
      $stderr.puts 'http request failed'
      return nil
    end
    JSON.parse(res.body)
  rescue
    nil
  end

  def self.get_list_of_services()
    get_request('/catalog/services').keys
  end

  def self.get_leader_for_service(service_name)
    leader_info_meta = get_request("/kv/service/#{service_name}/leader")
    return nil if leader_info_meta == nil or leader_info_meta.size == 0
    return nil if leader_info_meta[0]['Session'] == nil #no session for key means no leader
    leader_info = get_request("/kv/service/#{service_name}/leader?raw")
    "#{leader_info['Address']}:#{leader_info['Port']}"
  end

  def self.get_self_node_name()
    node_info = get_request('/agent/self')
    return 'not-running-consul' if not node_info
    node_info['Config']['NodeName']
  end

  def self.is_current_node_leader(service_name)
    leader_info_meta = get_request("/kv/service/#{service_name}/leader")
    return false if leader_info_meta == nil or leader_info_meta.size == 0
    return false if leader_info_meta[0]['Session'] == nil #no session for key means no leader
    leader_info = get_request("/session/info/#{leader_info_meta[0]['Session']}")
    return false if leader_info == {}
    return false if leader_info.size == 0
    leader_info[0]["Node"] == get_self_node_name
  end

  def self.get_healthy_nodes_for_service(service_name)
    nodes_health = get_request("/health/service/#{service_name}")
    healthy_nodes = nodes_health.map do |node_info|
      health_check_statuses = node_info['Checks'].map {|cur_check| cur_check['Status']}
      if health_check_statuses.uniq == ['passing']
         "#{node_info['Node']['Address']}:#{node_info['Service']['Port']}"
      else
        nil
      end
    end
    {
      "nodes" => healthy_nodes.compact,
      "nodes_string" => healthy_nodes.compact.join(','),
      # "leader" => get_leader_for_service(service_name),
      "is_current_node_leader" => is_current_node_leader(service_name)
    }
  end

  def self.list_services()
    if not get_request('/status/peers')
      $stderr.puts 'consul agent not responding'
      return nil
    end
    services = {}
    get_list_of_services.map do |service_name|
      services[service_name] = get_healthy_nodes_for_service(service_name)
    end
    services
  end
end
