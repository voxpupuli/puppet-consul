# == Class consul::params
#
# This class is meant to be called from consul
# It sets variables according to platform
#
class consul::params {

  $install_method        = 'url'
  $package_name          = 'consul'
  $package_ensure        = 'latest'
  $download_url_base     = 'https://releases.hashicorp.com/consul/'
  $download_extension    = 'zip'
  $ui_package_name       = 'consul_ui'
  $ui_package_ensure     = 'latest'
  $ui_download_url_base  = 'https://releases.hashicorp.com/consul/'
  $ui_download_extension = 'zip'
  $version               = '0.5.2'
  $config_mode           = '0660'

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    /^arm.*/:          { $arch = 'arm'   }
    'x64':             {
      # 0.6.0 introduced a 64-bit version, so we need to differentiate:
      if (versioncmp($::consul::version, '0.6.0') < 0) {
        $arch = '386'
      } else {
        $arch = 'amd64'
      }
    }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }

  $os = downcase($::kernel)

  case $::operatingsystem {
    'windows': {
      $bin_dir = $::consul_windir
      $config_dir = "${bin_dir}/config"
    }
    default: {
      $bin_dir = '/usr/local/bin'
      $config_dir = '/etc/consul'
    }
  }

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
      $init_style = 'init'
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
    $init_style = 'init'
  } elsif $::operatingsystem == 'windows' {
    $init_style = 'scm'
  } else {
    $init_style = undef
  }
  if $init_style == undef {
    fail('Unsupported OS')
  }
}
