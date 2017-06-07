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
  $config_dir            = '/etc/consul'
  $config_hash           = {}
  $config_mode           = '0660'
  $download_extension    = 'zip'
  $download_url          = undef
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
  $ui_download_extension = 'zip'
  $ui_download_url       = undef
  $ui_download_url_base  = 'https://releases.hashicorp.com/consul/'
  $ui_package_ensure     = 'latest'
  $ui_package_name       = 'consul_ui'
  $user                  = 'consul'
  $version               = '0.7.4'
  $watches               = {}

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    /^arm.*/:          { $arch = 'arm'   }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }

  $os = downcase($::kernel)

  if $::operatingsystem == 'Ubuntu' {
    if versioncmp($::operatingsystemrelease, '8.04') < 1 {
      $init_style = 'debian'
    } elsif versioncmp($::operatingsystemrelease, '15.04') < 0 {
      $init_style = 'upstart'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem =~ /Scientific|CentOS|RedHat|OracleLinux/ {
    if versioncmp($::operatingsystemrelease, '7.0') < 0 {
      $init_style = 'redhat'
    } else {
      $init_style  = 'systemd'
    }
  } elsif $::operatingsystem == 'Fedora' {
    if versioncmp($::operatingsystemrelease, '12') < 0 {
      $init_style = 'init'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Debian' {
    if versioncmp($::operatingsystemrelease, '8.0') < 0 {
      $init_style = 'debian'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Archlinux' {
    $init_style = 'systemd'
  } elsif $::operatingsystem == 'OpenSuSE' {
    $init_style = 'systemd'
  } elsif $::operatingsystem =~ /SLE[SD]/ {
    if versioncmp($::operatingsystemrelease, '12.0') < 0 {
      $init_style = 'sles'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Darwin' {
    $init_style = 'launchd'
  } elsif $::operatingsystem == 'Amazon' {
    $init_style = 'redhat'
  } elsif $::operatingsystem == 'FreeBSD' {
    $init_style = 'freebsd'
  } else {
    fail('Cannot determine init_style, unsupported OS')
  }
}
