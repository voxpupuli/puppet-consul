# == Define consul::service
#
# Sets up a Consul service definition
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
#   IP address the service is running at.
#
# [*port*]
#   TCP port the service runs on.
#
# [*checks*]
#   If provided an array of checks that will be added to this service
#
define consul::service(
  $service_name   = $title,
  $id             = $title,
  $tags           = [],
  $address        = undef,
  $port           = undef,
  $checks         = [],
) {
  include consul

  consul_validate_checks($checks)

  $basic_hash = {
    'id'      => $id,
    'name'    => $service_name,
    'address' => $address,
    'tags'    => $tags,
    'checks'  => $checks
  }

  if $port {
    # implicit conversion from string to int so it won't be quoted in JSON
    $port_hash = {
      port => $port * 1
    }
  } else {
    $port_hash = {}
  }

  $service_hash = {
    service => delete_undef_values(merge($basic_hash, $port_hash))
  }

  File[$consul::config_dir] ->
  file { "${consul::config_dir}/service_${id}.json":
    content => consul_sorted_json($service_hash),
  } ~> Class['consul::run_service']
}
