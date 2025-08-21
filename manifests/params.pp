# == Class consul::params
#
# This class is meant to be called from consul
# It sets variables according to platform
#
# @api private
class consul::params {
  case $facts['os']['architecture'] {
    'x86_64', 'x64', 'amd64': { $arch = 'amd64' }
    'i386':                   { $arch = '386' }
    'aarch64':                { $arch = 'arm64' }
    'armv7l':                 { $arch = 'armhfv6' }
    /^arm.*/:                 { $arch = 'arm' }
    default:                  {
      fail("Unsupported kernel architecture: ${facts['os']['architecture']}")
    }
  }

  $config_dir = $facts['os']['family'] ? {
    'FreeBSD' => '/usr/local/etc/consul.d',
    'windows' => 'C:\\ProgramData\\consul\\config',
    default   => '/etc/consul'
  }

  $bin_dir = $facts['os']['family'] ? {
    'windows' => 'C:\\ProgramData\\consul',
    default   => '/usr/local/bin'
  }

  case $facts['os']['name'] {
    'windows': {
      $data_dir_mode = '0775'
      $binary_group = undef
      $binary_mode = '0775'
      $binary_name = 'consul.exe'
      $binary_owner = 'NT AUTHORITY\NETWORK SERVICE'
      $config_defaults  = {
        data_dir => 'C:\\ProgramData\\consul',
      }
      $manage_user = false
      $manage_group = false
      $user = 'NT AUTHORITY\NETWORK SERVICE'
      $group = 'Administrators'
    }
    default: {
      # 0 instead of root because OS X uses "wheel".
      $data_dir_mode = '0755'
      $binary_group = '0'
      $binary_mode = '0555'
      $binary_name = 'consul'
      $binary_owner = 'root'
      $config_defaults  = {
        data_dir => '/opt/consul',
      }
      $manage_user = true
      $manage_group = true
      $user = 'consul'
      $group = 'consul'
    }
  }

  case $facts['os']['name'] {
    'Ubuntu': {
      $bash_completion = true
      $shell = '/usr/sbin/nologin'
    }
    'RedHat': {
      $bash_completion = false
      $shell = '/sbin/nologin'
    }
    'Debian': {
      $bash_completion = true
      $shell = '/usr/sbin/nologin'
    }
    'Archlinux': {
      $bash_completion = false
      $shell = '/sbin/nologin'
    }
    'OpenSuSE': {
      $bash_completion = false
      $shell = '/usr/sbin/nologin'
    }
    /SLE[SD]/: {
      $bash_completion = false
      $shell = '/usr/sbin/nologin'
    }
    default: {
      $bash_completion = false
      $shell = undef
    }
  }

  if $facts['os']['family'] == 'windows' {
    $init_style = 'unmanaged'
  } else {
    $init_style = $facts['service_provider'] ? {
      undef   => 'systemd',
      default => $facts['service_provider']
    }
  }
}
