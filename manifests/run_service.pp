# == Class consul::service
#
# This class is meant to be called from consul
# It ensure the service is running
#
class consul::run_service {

  service { 'consul':
    ensure     => $consul::service_ensure,
    enable     => $consul::service_enable,
  }

  if $consul::join_cluster {
    exec { 'join consul cluster':
      cwd         => $consul::config_dir,
      path        => $consul::bin_dir,
      command     => "consul join ${consul::join_cluster}",
      refreshonly => true,
      subscribe   => Service['consul'],
    }
  }

}
