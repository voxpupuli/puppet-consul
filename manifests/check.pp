# == Define consul::check
#
# Sets up a Consul healthcheck. One of script, http, or ttl must be specified
# http://www.consul.io/docs/agent/checks.html
#
# == Parameters
#
# [*id*]
#   Optional. ID for this check, must be unique.
#
# [*check_name*]
#   Optional. Name for this check. If unspecified, defaults to the resource
#   name.
#
# [*script*]
#   Full path to the location of the healthcheck script. Must be nagios
#   compliant with regards to the return codes.
#
# [*http*]
#   URL to check.
#
# [*ttl*]
#   Value in seconds before the http endpoint considers a failing healthcheck
#   to be "HARD" down.
#
# [*service_id*]
#   Optional. Name of a service to associate this check with.
#
# [*interval*]
#   Time interval between runs of the check. Only defined for script and
#   HTTP checks.
#
# [*timeout*]
#   How long the check should run before timing out. Only defined for HTTP
#   checks.
#
# [*notes*]
#   Human readable description of the check
#
define consul::check(
  $id         = undef,
  $check_name = $title,
  $script     = undef,
  $http       = undef,
  $ttl        = undef,
  $service_id = undef,
  $interval   = undef,
  $timeout    = undef,
  $notes      = undef,
) {
  include consul

  $check_hash_all = {
    'id'         => $id,
    'name'       => $check_name,
    'script'     => $script,
    'http'       => $http,
    'ttl'        => $ttl,
    'service_id' => $service_id,
    'interval'   => $interval,
    'timeout'    => $timeout,
    'notes'      => $notes,
  }

  $check_hash = { 'check' => delete_undef_values($check_hash_all) }

  File[$consul::config_dir] ->
  file { "${consul::config_dir}/check_${check_name}.json":
    content => template('consul/check.json.erb'),
  } ~> Class['consul::run_service']
}
