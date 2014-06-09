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

}
