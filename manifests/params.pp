# == Class consul::params
#
# This class is meant to be called from consul
# It sets variables according to platform
#
class consul::params {

  $install_method = 'url'
  $package_name   = 'consul'
  $package_ensure = 'latest'
  $version = '0.2.0'

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    default:           { fail("Unsupported kernel architecture: ${::architecture}") }
  }

  $init_style = $::operatingsystem ? {
    'Ubuntu'             => $::lsbdistrelease ? {
      '8.04'           => 'hardy',
      /(10|12|14)\.04/ => 'upstart',
      default => undef
    },
    'CentOS'             => 'redhat',
    'RedHat'             => 'redhat',
    default => undef
  }
}
