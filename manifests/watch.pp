
define consul::watch(
  $handler      = undef,
  $datacenter   = undef,
  $token        = undef,
  $type         = undef,
  $key          = undef,
  $keyprefix    = undef,
  $service      = undef,
  $service_tag  = undef, #Note: this actually maps to the "tag" param for service watches
  $passingonly  = undef,
  $state        = undef,
  $event_name   = undef, #Note: this actually maps to the "name" param for event watches
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
        keyprefix => $keyprefix,
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
    content => template('consul/watch.json.erb'),
  } ~> Class['consul::run_service']
}
