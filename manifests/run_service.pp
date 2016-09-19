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

  if $::consul::join_wan {
    exec { 'join consul wan':
      cwd       => $::consul::config_dir,
      path      => [$::consul::bin_dir,'/bin','/usr/bin'],
      command   => "consul join -wan ${consul::join_wan}",
      unless    => "consul members -wan -detailed | grep -vP \"dc=${consul::config_hash_real['datacenter']}\" | grep -P 'alive'",
      subscribe => Service['consul'],
    }
  }

}
