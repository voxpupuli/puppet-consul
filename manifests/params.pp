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
  $version = '0.4.1'

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    default:           { fail("Unsupported kernel architecture: ${::architecture}") }
  }

  $os = downcase($::kernel)

  $init_style = $::operatingsystem ? {
    'Ubuntu' => versioncmp($::lsbdistrelease, '8.04') ? {
      '-1' => 'debian',
      '0'  => 'debian',
      '1'  => 'upstart',
    },
    /CentOS|RedHat/ => versioncmp($::operatingsystemrelease, '7.0') ? {
      '-1' => 'sysv',
      '0'  => 'systemd',
      '1'  => 'systemd'
    },
    'Fedora' => versioncmp($::operatingsystemrelease, '12') ? {
      '-1' => 'sysv',
      '0'  => 'systemd',
      '1'  => 'systemd'
    },
    'Debian'             => 'debian',
    'SLES'               => 'sles',
    'Darwin'             => 'launchd',
    default => undef
  }
  if $init_style == undef {
    fail("Unsupported O/S")
  }
}
