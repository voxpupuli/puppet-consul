# == Class consul::service
#
# This class is meant to be called from consul
# It ensure the service is running
#
class consul::run_service {

  $service_name = $consul::init_style_real ? {
    'launchd' => 'io.consul.daemon',
    default   => 'consul',
  }

  $service_provider = $consul::init_style_real ? {
    'unmanaged' => undef,
    default     => $consul::init_style_real,
  }

  if $consul::manage_service == true and $consul::install_method != 'docker' {
    if $facts['os']['name'] == 'windows' {
      class { 'consul::windows_service':
        before => Service['consul'],
      }
    }

    service { 'consul':
      ensure   => $consul::service_ensure,
      name     => $service_name,
      enable   => $consul::service_enable,
      provider => $service_provider,
    }
  }

  if $consul::install_method == 'docker' {

    $server_mode = pick($consul::config_hash[server], false)

    if $server_mode {
      $env = [ '\'CONSUL_ALLOW_PRIVILEGED_PORTS=\'' ]
      $docker_command = 'agent -server'
    } else {
      $env = undef
      $docker_command = 'agent'
    }

    docker::run { 'consul':
      image   => "${consul::docker_image}:${consul::version}",
      net     => 'host',
      volumes => ["${consul::config_dir}:/consul/config", "${consul::data_dir}:/consul/data"],
      env     => $env,
      command => $docker_command,
    }
  }

  case $consul::install_method {
    'docker': {
      $wan_command = "docker exec consul consul join -wan ${consul::join_wan}"
      $wan_unless = "docker exec consul consul members -wan -detailed | grep -vP \"dc=${consul::config_hash_real['datacenter']}\" | grep -P 'alive'"  #lint:ignore:140chars
    }
    default: {
      $wan_command = "consul join -wan ${consul::join_wan}"
      $wan_unless = "consul members -wan -detailed | grep -vP \"dc=${consul::config_hash_real['datacenter']}\" | grep -P 'alive'"
    }
  }

  if $consul::join_wan {
    exec { 'join consul wan':
      cwd       => $consul::config_dir,
      path      => [$consul::bin_dir,'/bin','/usr/bin'],
      command   => $wan_command,
      unless    => $wan_unless,
      subscribe => Service['consul'],
    }
  }
}
