# == Define: consul::watch
#
# Sets up Consul watch, to span commands when data changes.
# http://www.consul.io/docs/agent/watches.html
#
# == Parameters
#
# [*ensure*]
#   Define availability of watch. Use 'absent' to remove existing watches.
#   Defaults to 'present'
#
# [*handler*]
#   Full path to the script that will be excuted.
#
# [*datacenter*]
#   String overriding consul's default datacenter.
#
# [*token*]
#   String to override the default token.
#
# [*type*]
#   Type of data to watch. (Like key, service, services, nodes)
#
# [*key*]
#   Watch a specific key.
#
# [*keyprefix*]
#   Watch a whole keyprefix
#
# [*service*]
#   Watch a particular service
#
# [*service_tag*]
#   This actually maps to the "tag" param for service watches.
#   (`tag` is a puppet builtin metaparameter)
#
# [*passingonly*]
#   Watch only those services that are passing healthchecks.
#
# [*state*]
#   Watch a state change on a service healthcheck.
#
# [*event_name*]
#   Name of an event to watch for.
#
define consul::watch(
  $ensure       = present,
  $handler      = undef,
  $datacenter   = undef,
  $token        = undef,
  $type         = undef,
  $key          = undef,
  $keyprefix    = undef,
  $service      = undef,
  $service_tag  = undef,
  $passingonly  = undef,
  $state        = undef,
  $event_name   = undef,
) {
  include consul
  $id = $title

  $basic_hash = {
    'type'       => $type,
    'handler'    => $handler,
    'datacenter' => $datacenter,
    'token'      => $token,
  }

  if (versioncmp($::consul::version, '0.4.0') < 0) {
    fail ('Watches are only supported in Consul 0.4.0 and above')
  }

  if (! $handler ) {
    fail ('All watch conditions must have a handler defined')
  }

  if (! $type ) {
    fail ('All watch conditions must have a type defined')
  }

  if ($passingonly ) {
    validate_bool($passingonly)
  }

  case $type {
    'key': {
      if (! $key ) {
        fail('key is required for watch type [key]')
      }
      $type_hash = {
        key => $key,
      }
    }
    'keyprefix': {
      if (! $keyprefix ) {
        fail('keyprefix is required for watch type of [keyprefix]')
      }
      $type_hash = {
        prefix => $keyprefix,
      }
    }
    'service': {
      if (! service ){
        fail('service is required for watch type of [service]')
      }
      $type_hash = {
        service     => $service,
        tag         => $service_tag,
        passingonly => $passingonly,
      }
    }
    'checks': {
      $type_hash = {
        service => $service,
        state   => $state,
      }
    }
    'event': {
      $type_hash = {
        name => $event_name,
      }
    }
    /(nodes|services)/: {
      $type_hash = {}
    }
    default: {
      fail("${type} is an unrecogonized watch type that is not supported currently")
    }
  }

  $watch_hash = {
    watches => [delete_undef_values(merge($basic_hash, $type_hash))]
  }

  File[$consul::config_dir] ->
  file { "${consul::config_dir}/watch_${id}.json":
    ensure  => $ensure,
    owner   => $consul::user,
    group   => $consul::group,
    mode    => $consul::config_mode,
    content => consul_sorted_json($watch_hash, $consul::pretty_config, $consul::pretty_config_indent),
  } ~> Class['consul::reload_service']
}
