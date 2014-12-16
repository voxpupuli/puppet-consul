define consul::service(
  $service_name   = $title,
  $tags           = [],
  $port           = undef,
  $check_ttl      = undef,
  $check_script   = undef,
  $check_interval = undef,
) {
  include consul
  $id = $title

  $basic_hash = {
    'id'   => $id,
    'name' => $service_name,
    'tags' => $tags,
  }

  if $check_ttl and $check_interval {
    fail("Only one of check_ttl and check_interval can be defined")
  }

  if $check_ttl {
    if $check_script {
      fail("check_script must not be defined for ttl checks")
    }
    $check_hash = {
      check => {
        ttl => $check_ttl,
      }
    }
  } elsif $check_interval {
    if (! $check_script) {
      fail("check_script must be defined for interval checks")
    }
    $check_hash = {
      check => {
        script   => $check_script,
        interval => $check_interval,
      }
    }
  } else {
    $check_hash = {}
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
    service => merge($basic_hash, $check_hash, $port_hash)
  }

  File[$consul::config_dir] ->
  file { "${consul::config_dir}/service_${id}.json":
    content => consul_sorted_json($service_hash),
  } ~> Class['consul::run_service']
}
