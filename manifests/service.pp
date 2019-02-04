# == Define consul::service
#
# Sets up a Consul service definition
# http://www.consul.io/docs/agent/services.html
#
# == Parameters
#
# [*address*]
#   IP address the service is running at.
#
# [*checks*]
#   If provided an array of checks that will be added to this service
#
# [*enable_tag_override*]
#   enable_tag_override support for service. Defaults to False.
#
# [*ensure*]
#   Define availability of service. Use 'absent' to remove existing services.
#   Defaults to 'present'
#
# [*id*]
#   The unique ID of the service on the node. Defaults to title.
#
# [*port*]
#   TCP port the service runs on.
#
# [*service_name*]
#   Name of the service. Defaults to title.
#
# [*service_config_hash*]
#   Use this to populate the basic service params for each of the services
#
# [*tags*]
#   Array of strings.
#
# [*token*]
#   ACL token for interacting with the catalog (must be 'management' type)
#
# [*meta*]
#   Service meta key/value pairs as hash.
#
# === Examples
# @example
#  consul::service { 'my_db':
#    port                => 3306,
#    tags                => ['db','mysql'],
#    address             => '1.2.3.4',
#    token               => 'xxxxxxxxxx',
#    service_config_hash =>  {
#      'connect' => {
#        'sidecar_service' => {},
#      },
#    },
#    checks              => [
#      {
#        name     => 'MySQL Port',
#        tcp      => 'localhost:3306',
#        interval => '10s',
#      },
#    ],
#  }
#
define consul::service(
  $address                                   = undef,
  $checks                                    = [],
  $enable_tag_override                       = false,
  $ensure                                    = present,
  $id                                        = $title,
  $port                                      = undef,
  $service_name                              = $title,
  Hash $service_config_hash                  = {},
  $tags                                      = [],
  $token                                     = undef,
  Optional[Hash[String[1], String[1]]] $meta = undef,
) {

  include consul

  consul::validate_checks($checks)

  if versioncmp($consul::version, '1.0.0') >= 0 {
    $override_key = 'enable_tag_override'
  } else {
    $override_key = 'enableTagOverride'
  }

  $default_config_hash = {
    'id'                => $id,
    'name'              => $service_name,
    'address'           => $address,
    'port'              => $port,
    'tags'              => $tags,
    'checks'            => $checks,
    'token'             => $token,
    'meta'              => $meta,
    $override_key       => $enable_tag_override,
  }

  $basic_hash = $default_config_hash + $service_config_hash

  $service_hash = {
    service => delete_undef_values($basic_hash),
  }

  $escaped_id = regsubst($id,'\/','_','G')
  file { "${consul::config_dir}/service_${escaped_id}.json":
    ensure  => $ensure,
    owner   => $consul::user_real,
    group   => $consul::group_real,
    mode    => $consul::config_mode,
    content => consul::sorted_json($service_hash, $consul::pretty_config, $consul::pretty_config_indent),
    require => File[$consul::config_dir],
  } ~> Class['consul::reload_service']
}
