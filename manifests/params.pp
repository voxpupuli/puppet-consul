# == Class consul::params
#
# This class is meant to be called from consul
# It sets variables according to platform
#
class consul::params {
  $acls                  = {}
  $archive_path          = ''  #lint:ignore:empty_string_assignment
  $checks                = {}
  $config_defaults       = {}
  $config_hash           = {}
  $config_mode           = '0664'
  $docker_image          = 'consul'
  $download_extension    = 'zip'
  $download_url_base     = 'https://releases.hashicorp.com/consul/'
  $extra_groups          = []
  $extra_options         = ''  #lint:ignore:empty_string_assignment
  $log_file              = '/var/log/consul'
  $install_method        = 'url'
  $join_wan              = false
  $manage_service        = true
  $package_ensure        = 'latest'
  $package_name          = 'consul'
  $pretty_config         = false
  $pretty_config_indent  = 4
  $purge_config_dir      = true
  $restart_on_change     = true
  $service_enable        = true
  $service_ensure        = 'running'
  $services              = {}
  $service_config_hash   = {}
  $version               = '1.2.3'
  $watches               = {}

  case $facts['architecture'] {
    'x86_64', 'x64', 'amd64': { $arch = 'amd64' }
    'i386':                   { $arch = '386'   }
    'aarch64':                { $arch = 'arm64' }
    /^arm.*/:                 { $arch = 'arm'   }
    default:                  {
      fail("Unsupported kernel architecture: ${facts['architecture']}")
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

  $os = downcase($facts['kernel'])

  case $facts['os']['name'] {
    'windows': {
      $data_dir_mode = '0775'
      $binary_group = undef
      $binary_mode = '0775'
      $binary_name = 'consul.exe'
      $binary_owner = 'NT AUTHORITY\NETWORK SERVICE'
      $manage_user = false
      $manage_group = false
      $user = 'NT AUTHORITY\NETWORK SERVICE'
      $group = 'Administrators'
    }
    default: {
      # 0 instead of root because OS X uses "wheel".
      $data_dir_mode = '0755'
      $binary_group = 0
      $binary_mode = '0555'
      $binary_name = 'consul'
      $binary_owner = 'root'
      $manage_user = true
      $manage_group = true
      $user = 'consul'
      $group = 'consul'
    }
  }

  case $facts['os']['name'] {
    'Ubuntu': {
      $shell = '/usr/sbin/nologin'
    }
    'RedHat': {
      $shell = '/sbin/nologin'
    }
    'Debian': {
      $shell = '/usr/sbin/nologin'
    }
    'Archlinux': {
      $shell = '/sbin/nologin'
    }
    'OpenSuSE': {
      $shell = '/usr/sbin/nologin'
    }
    /SLE[SD]/: {
      $shell = '/usr/sbin/nologin'
    }
    default: {
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
