# == Class consul::service
#
# This class is meant to be called from consul
# It ensure the service is running
#
class consul::run_service {

  service { 'consul':
    name       => $consul::init_style ? {
      'launchd' => 'io.consul.daemon',
      default   => 'consul'
    },
    ensure     => $consul::service_ensure,
    enable     => $consul::service_enable,
  }

  if $consul::join_wan {
    exec { 'join consul wan':
      cwd         => $consul::config_dir,
      path        => [$consul::bin_dir,'/bin','/usr/bin'],
      command     => "consul join -wan ${consul::join_wan}",
      onlyif      => "consul members -wan -detailed | grep -vP \"dc=${consul::_config_hash['datacenter']}\" | grep -P 'alive'",
      subscribe   => Service['consul'],
    }
  }

}
