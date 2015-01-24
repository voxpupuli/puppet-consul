# == Define consul::check
#
# Sets up a Consul healthcheck
# http://www.consul.io/docs/agent/checks.html
#
# == Parameters
#
# [*ttl*]
#   Value in seconds before the http endpoint considers a failing healthcheck
#   to be "HARD" down.
#
# [*script*]
#   Full path to the location of the healthcheck script. Must be nagios
#   compliant with regards to the return codes.
#
# [*interval*]
#   Value in seconds for the interval between runs of the check
#
# [*notes*]
#   Human readable description of the check
#
define consul::check(
  $ttl      = undef,
  $script   = undef,
  $interval = undef,
  $notes    = undef,
) {
  include consul
  $id = $title

  $basic_hash = {
    'id'   => $id,
    'name' => $name,
  }

  if $ttl and $interval {
    fail('Only one of ttl and interval can be defined')
  }

  if $ttl {
    if $script {
      fail('script must not be defined for ttl checks')
    }
    $check_definition = {
      ttl => $ttl,
    }
  } elsif $interval {
    if (! $script) {
      fail('script must be defined for interval checks')
    }
    $check_definition = {
      script   => $script,
      interval => $interval,
    }
  } else {
    fail('One of ttl or interval must be defined.')
  }

  if $notes {
    $notes_hash = {
      notes => $notes
    }
  } else {
    $notes_hash = {}
  }

  $check_hash = {
    check => merge($basic_hash, $check_definition, $notes_hash)
  }

  File[$consul::config_dir] ->
  file { "${consul::config_dir}/check_${id}.json":
    content => template('consul/check.json.erb'),
  } ~> Class['consul::run_service']
}
