# == Define consul::check
#
# Sets up a Consul healthcheck
# http://www.consul.io/docs/agent/checks.html
#
# == Parameters
#
# [*id*]
#   The id for the check (defaults to $title)
#
# [*check_ensure*]
#   Ensure state of the check. (defaults to present)
#
# [*ttl*]
#   Value in seconds before the http endpoint considers a failing healthcheck
#   to be "HARD" down.
#
# [*http*]
#   HTTP endpoint for the service healthcheck
#
# [*script*]
#   Full path to the location of the healthcheck script. Must be nagios
#   compliant with regards to the return codes.
#
# [*script_source*]
#   Full puppet path to the location of the healthcheck script to deploy.
#   ie: 'puppet:///modules/consul_checks/check.sh'
#
# [*script_path*]
#   Where to deploy service check script
#
# [*interval*]
#   Value in seconds for the interval between runs of the check
#
# [*service_id*]
#   An optional service_id to match this check against
#
# [*timeout*]
#   A timeout value for HTTP request only
#
# [*notes*]
#   Human readable description of the check
#
define consul::check(
  $id            = $title,
  $check_ensure  = present,
  $ttl           = undef,
  $http          = undef,
  $script        = undef,
  $script_source = undef,
  $script_path   = undef,
  $interval      = undef,
  $service_id    = undef,
  $timeout       = undef,
  $notes         = undef,
) {
  include consul

  # Deploy script if necessary
  if $script_source {
    file { "${id}":
      ensure => $check_ensure,
      source => $script_source,
      path   => $script_path,
      mode   => 755,
    }
  }

  $basic_hash = {
    'id'         => $id,
    'name'       => $name,
    'ttl'        => $ttl,
    'http'       => $http,
    'script'     => $script,
    'interval'   => $interval,
    'timeout '   => $timeout,
    'service_id' => $service_id,
    'notes'      => $notes,
  }

  $check_hash = {
    check => delete_undef_values($basic_hash)
  }

  consul_validate_checks($check_hash[check])

  File[$consul::config_dir] ->
  file { "${consul::config_dir}/check_${id}.json":
    content => template('consul/check.json.erb'),
    ensure  => $check_ensure,
  } ~> Class['consul::run_service']
}
