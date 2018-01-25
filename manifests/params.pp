# == Class consul::params
#
# This class is meant to be called from consul
# It sets variables according to platform
#
class consul::params {
  $acls                  = {}
  $archive_path          = ''
  $bin_dir               = '/usr/local/bin'
  $checks                = {}
  $config_defaults       = {}
  $config_hash           = {}
  $config_mode           = '0664'
  $docker_image          = 'consul'
  $download_extension    = 'zip'
  $download_url_base     = 'https://releases.hashicorp.com/consul/'
  $extra_groups          = []
  $extra_options         = ''
  $group                 = 'consul'
  $log_file              = '/var/log/consul'
  $install_method        = 'url'
  $join_wan              = false
  $manage_group          = true
  $manage_service        = true
  $manage_user           = true
  $package_ensure        = 'latest'
  $package_name          = 'consul'
  $pretty_config         = false
  $pretty_config_indent  = 4
  $purge_config_dir      = true
  $restart_on_change     = true
  $service_enable        = true
  $service_ensure        = 'running'
  $services              = {}
  $user                  = 'consul'
  $version               = '0.7.4'
  $watches               = {}

  case $::architecture {
    'x86_64', 'x64', 'amd64': { $arch = 'amd64' }
    'i386':                   { $arch = '386'   }
    /^arm.*/:                 { $arch = 'arm'   }
    default:                  {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }

  $config_dir = $::osfamily ? {
    'FreeBSD' => '/usr/local/etc/consul.d',
    'windows' => 'c:/Consul/config',
    default   => '/etc/consul'
  }

  $os = downcase($::kernel)

  if $::operatingsystem == 'Ubuntu' {
    $shell = '/usr/sbin/nologin'
    if versioncmp($::operatingsystemrelease, '8.04') < 1 {
      $init_style = 'debian'
    } elsif versioncmp($::operatingsystemrelease, '15.04') < 0 {
      $init_style = 'upstart'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::osfamily == 'RedHat' {
    $shell = '/sbin/nologin'
    case $::operatingsystem {
      'Fedora': {
        if versioncmp($::operatingsystemrelease, '12') < 0 {
          $init_style = 'init'
        } else {
          $init_style = 'systemd'
        }
      }
      'Amazon': {
        if versioncmp($::operatingsystemrelease, '2010') < 0{
          $init_style = 'systemd'
        } else {
          $init_style = 'redhat'
        }
      }
      default: {
        if versioncmp($::operatingsystemrelease, '7.0') < 0 {
          $init_style = 'redhat'
        } else {
          $init_style  = 'systemd'
        }
      }
    }
  } elsif $::operatingsystem == 'Debian' {
    $shell = '/usr/sbin/nologin'
    if versioncmp($::operatingsystemrelease, '8.0') < 0 {
      $init_style = 'debian'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Archlinux' {
    $shell = '/sbin/nologin'
    $init_style = 'systemd'
  } elsif $::operatingsystem == 'OpenSuSE' {
    $shell = '/usr/sbin/nologin'
    $init_style = 'systemd'
  } elsif $::operatingsystem =~ /SLE[SD]/ {
    $shell = '/usr/sbin/nologin'
    if versioncmp($::operatingsystemrelease, '12.0') < 0 {
      $init_style = 'sles'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Darwin' {
    $shell = undef
    $init_style = 'launchd'
  } elsif $::operatingsystem == 'FreeBSD' {
    $init_style = 'freebsd'
    $shell = '/usr/sbin/nologin'
  } elsif $::operatingsystem == 'windows' {
    $init_style = 'unmanaged'
    $shell = undef
  } else {
    fail('Cannot determine init_style, unsupported OS')
  }
}
