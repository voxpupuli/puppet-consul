# == Class consul::reload_service
#
# This class is meant to be called from certain
# configuration changes that support reload.
#
# https://www.consul.io/docs/agent/options.html#reloadable-configuration
#
class consul::reload_service {

  exec { 'reload consul service':
    path        => [$consul::bin_dir,'/bin','/usr/bin'],
    command     => 'consul reload',
    refreshonly => true,
  }

}
