# == Class consul::service
#
# This class is meant to be called from consul
# It ensure the service is running
#
class consul::run_service {

  $init_selector = $consul::init_style ? {
    'launchd' => 'io.consul.daemon',
    default   => 'consul',
  }

  if $consul::manage_service == true and $consul::init_style {
    service { 'consul':
      ensure   => $consul::service_ensure,
      name     => $init_selector,
      enable   => $consul::service_enable,
      provider => $consul::init_style,
    }
  }

  if $consul::join_wan {
    exec { 'join consul wan':
      cwd       => $consul::config_dir,
      path      => [$consul::bin_dir,'/bin','/usr/bin'],
      command   => "consul join -wan ${consul::join_wan}",
      unless    => "consul members -wan -detailed | grep -vP \"dc=${consul::config_hash_real['datacenter']}\" | grep -P 'alive'",
      subscribe => Service['consul'],
    }
  }

}
