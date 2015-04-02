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
  $id         = $title,
  $ttl        = undef,
  $http       = undef,
  $script     = undef,
  $interval   = undef,
  $service_id = undef,
  $timeout    = undef,
  $notes      = undef,
) {
  include consul

  $basic_hash = {
    'id'         => $id,
    'name'       => $name,
    'service_id' => $service_id,
    'notes'      => $notes,
  }

  if $http and $script {
    fail('Only one of script and http can be defined')
  }

  if $ttl {
    if $script or $http {
      fail('script or http must not be defined for ttl checks')
    }
    if $timeout {
      warning('timeout only valid for http requests')
    }
    $check_definition = {
      ttl => $ttl,
    }
  } elsif $http {
    if (! $interval) {
      fail('http must be defined for interval checks')
    }
    $check_definition = {
      http       => $http,
      interval   => $interval,
      timeout    => $timeout,
    }
  } elsif $script {
    if (! $interval) {
      fail('script must be defined for interval checks')
    }
    if $timeout {
      warning('timeout only valid for http requests')
    }
    $check_definition = {
      script     => $script,
      interval   => $interval,
    }
  } else {
    fail('One of ttl, script, or http must be defined.')
  }

  $check_hash = {
    check => delete_undef_values(merge($basic_hash, $check_definition))
  }

  File[$consul::config_dir] ->
  file { "${consul::config_dir}/check_${id}.json":
    content => template('consul/check.json.erb'),
  } ~> Class['consul::run_service']
}
