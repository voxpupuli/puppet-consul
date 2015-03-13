# == Define consul::service
#
# Sets up a Consul service definition. To define a check for a service,
# set the 'service_id' field in the check resource to the name of this
# resource.
# http://www.consul.io/docs/agent/services.html
#
# == Parameters
#
# [*service_name*]
#   Name of the service. Defaults to title.
#
# [*id*]
#   The unique ID of the service on the node. Defaults to title.
#
# [*tags*]
#   Array of strings.
#
# [*address*]
#   Optional. IP address for the service.
#
# [*port*]
#   TCP port the service runs on.
#
define consul::service(
  $id             = undef,
  $service_name   = $title,
  $tags           = [],
  $address        = undef,
  $port           = undef,
) {
  include consul

  $service_hash_all = {
    'id'      => $id,
    'name'    => $service_name,
    'tags'    => $tags,
    'address' => $address,
    'port'    => $port,
  }

  $serice_hash = { 'service' => delete_undef_values($service_hash_all) }

  File[$consul::config_dir] ->
  file { "${consul::config_dir}/service_${service_name}.json":
    content => template('consul/service.json.erb'),
  } ~> Class['consul::run_service']
}
