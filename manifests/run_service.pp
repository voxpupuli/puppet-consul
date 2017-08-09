# == Class consul::service
#
# This class is meant to be called from consul
# It ensure the service is running
#
class consul::run_service {

  $service_name = $::consul::init_style ? {
    'launchd' => 'io.consul.daemon',
    default   => 'consul',
  }

  $service_provider = $::consul::init_style ? {
    'unmanaged' => undef,
    default     => $::consul::init_style,
  }

  if $::consul::manage_service == true {
    service { 'consul':
      ensure   => $::consul::service_ensure,
      name     => $service_name,
      enable   => $::consul::service_enable,
      provider => $service_provider,
    }
  }

  if $::consul::install_method == 'docker' {
    
    $server_mode = pick($::consul::config_hash[server], false)
      
    if $server_mode {
      $env = [ '\'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}\'', '\'CONSUL_ALLOW_PRIVILEGED_PORTS=\'']
      $command = "agent -server"
    }
    else {
      $env = [ '\'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}\'' ]
      $command = "agent"
    }

    # Docker Install
    docker::run { 'consul' :
      image   => "${consul::docker_image}:${consul::version}",
      net     => 'host',
      volumes => [ "${::consul::config_dir}:/consul/config" ],
      env     => $env,
      command => $command
    }
  }

  case $::consul::install_method {
    'docker': { 
      $command = "docker exec -t consul consul join -wan ${consul::join_wan}"
      $unless = "docker exec -t consul consul members -wan -detailed | grep -vP \"dc=${consul::config_hash_real['datacenter']}\" | grep -P 'alive'"
    }
    default: { 
      $command = "consul join -wan ${consul::join_wan}"
      $unless = "consul members -wan -detailed | grep -vP \"dc=${consul::config_hash_real['datacenter']}\" | grep -P 'alive'"
    }
  }

  if $::consul::join_wan {
    exec { 'join consul wan':
      cwd       => $::consul::config_dir,
      path      => [$::consul::bin_dir,'/bin','/usr/bin'],
      command   => $command,
      unless    => $unless,
      subscribe => Service['consul'],
    }
  }
}
