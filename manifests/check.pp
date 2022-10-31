# @summary Sets up a Consul healthcheck
# @see http://www.consul.io/docs/agent/checks.html
#
# @param ensure Define availability of check. Use 'absent' to remove existing checks
# @param http HTTP endpoint for the service healthcheck
# @param id The id for the check (defaults to $title)
# @param interval Value in seconds for the interval between runs of the check
# @param notes Human readable description of the check
# @param script
#   Full path to the location of the healthcheck script. Must be nagios
#   compliant with regards to the return codes. This parameter is deprecated
#   in Consul 1.0.0, see https://github.com/hashicorp/consul/issues/3509.
#
# @param args Arguments to be `exec`ed for the healthcheck script.
# @param service_id An optional service_id to match this check against
# @param status The default state of the check when it is registered against a consul agent. Should be either "critical" or "passing"
# @param tcp The IP/hostname and port for the service healthcheck. Should be in 'hostname:port' format.
# @param timeout A timeout value for HTTP request only
# @param token ACL token for interacting with the catalog (must be 'management' type)
# @param ttl Value in seconds before the http endpoint considers a failing healthcheck to be "HARD" down.
# @param success_before_passing Value may be set to become check passing only after a specified number of consecutive checks return passing
# @param failures_before_critical Value may be set to become check critical only after a specified number of consecutive checks return critical
#
define consul::check (
  $ensure                   = present,
  $http                     = undef,
  $id                       = $title,
  $interval                 = undef,
  $notes                    = undef,
  $script                   = undef,
  $args                     = undef,
  $service_id               = undef,
  $status                   = undef,
  $tcp                      = undef,
  $timeout                  = undef,
  $token                    = undef,
  $ttl                      = undef,
  $success_before_passing   = undef,
  $failures_before_critical = undef,
) {
  include consul

  $basic_hash = {
    'id'                       => $id,
    'name'                     => $name,
    'ttl'                      => $ttl,
    'http'                     => $http,
    'script'                   => $script,
    'args'                     => $args,
    'tcp'                      => $tcp,
    'interval'                 => $interval,
    'timeout'                  => $timeout,
    'service_id'               => $service_id,
    'notes'                    => $notes,
    'token'                    => $token,
    'status'                   => $status,
    'success_before_passing'   => $success_before_passing,
    'failures_before_critical' => $failures_before_critical,
  }

  $check_hash = {
    check => $basic_hash.filter |$key, $val| { $val =~ NotUndef },
  }

  consul::validate_checks($check_hash[check])

  $escaped_id = regsubst($id,'\/','_','G')
  file { "${consul::config_dir}/check_${escaped_id}.json":
    ensure  => $ensure,
    owner   => $consul::user_real,
    group   => $consul::group_real,
    mode    => $consul::config_mode,
    content => consul::sorted_json($check_hash, $consul::pretty_config, $consul::pretty_config_indent),
    notify  => Class['consul::reload_service'],
  }
}
