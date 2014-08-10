# == Class consul::params
#
# This class is meant to be called from consul
# It sets variables according to platform
#
class consul::params {

  $install_method    = 'url'
  $package_name      = 'consul'
  $package_ensure    = 'latest'
  $ui_package_name   = 'consul_ui'
  $ui_package_ensure = 'latest'
  $version = '0.3.0'

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    default:           { fail("Unsupported kernel architecture: ${::architecture}") }
  }

  $init_style = $::operatingsystem ? {
    'Ubuntu'             => $::lsbdistrelease ? {
      '8.04'           => 'debian',
      /(10|12|14)\.04/ => 'upstart',
      default => undef
    },
    /CentOS|RedHat/      => $::operatingsystemmajrelease ? {
      /(4|5|6)/ => 'sysv',
      default   => 'systemd',
    },
    'Fedora'             => $::operatingsystemmajrelease ? {
      /(12|13|14)/ => 'sysv',
      default      => 'systemd',
    },
    'Debian'             => 'debian',
    default => undef
  }
}
