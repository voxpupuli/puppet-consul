# == Class consul::install
#
# Installs consul based on the parameters from init
#
class consul::install {

  case $::operatingsystem {
    'windows': {
      $binary_name = 'consul.exe'
      $binary_mode = '0775'
      $data_dir_mode = '775'
      $binary_owner = 'Administrators'
      $binary_group = 'Administrators'
    }
    default: {
      $binary_name = 'consul'
      $binary_mode = '0555'
      $data_dir_mode = '755'
      # 0 instead of root because OS X uses "wheel".
      $binary_owner = 'root'
      $binary_group = 0
    }
  }

  if $consul::data_dir {
    file { $consul::data_dir:
      ensure => 'directory',
      owner  => $consul::user_real,
      group  => $consul::group_real,
      mode   => '0755',
    }
  }

  case $consul::install_method {
    'docker': {
      # Do nothing as docker will install when run
    }
    'url': {
      $install_prefix = pick($consul::config_hash[data_dir], '/opt/consul')
      $install_path = pick($consul::archive_path, "${install_prefix}/archives")

      # only notify if we are installing a new version (work around for switching to archive module)
      if getvar('::consul_version') != $consul::version {
        $do_notify_service = $consul::notify_service
      } else {
        $do_notify_service = undef
      }

      include archive
      file { [
        $install_path,
        "${install_path}/consul-${consul::version}"]:
        ensure => directory,
        owner  => $binary_owner,
        group  => $binary_group,
        mode   => $binary_mode,
      }
      -> archive { "${install_path}/consul-${consul::version}.${consul::download_extension}":
        ensure       => present,
        source       => $consul::real_download_url,
        proxy_server => $consul::proxy_server,
        extract      => true,
        extract_path => "${install_path}/consul-${consul::version}",
        creates      => "${install_path}/consul-${consul::version}/${binary_name}",
      }
      -> file {
        "${install_path}/consul-${consul::version}/${binary_name}":
          owner => $binary_owner,
          group => $binary_group,
          mode  => $binary_mode;
        "${consul::bin_dir}/${binary_name}":
          ensure => link,
          notify => $do_notify_service,
          target => "${install_path}/consul-${consul::version}/${binary_name}";
      }
    }
    'package': {
      package { $consul::package_name:
        ensure => $consul::package_ensure,
        notify => $consul::notify_service
      }

      if $consul::manage_user {
        User[$consul::user_real] -> Package[$consul::package_name]
      }

      if $consul::data_dir {
        Package[$consul::package_name] -> File[$consul::data_dir]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${consul::install_method} is invalid")
    }
  }

  if ($consul::manage_user) and ($consul::install_method != 'docker' ) {
    user { $consul::user_real:
      ensure => 'present',
      system => true,
      groups => $consul::extra_groups,
      shell  => $consul::shell,
    }

    if ($consul::manage_group) and ($consul::install_method != 'docker' ) {
      Group[$consul::group_real] -> User[$consul::user_real]
    }
  }
  if ($consul::manage_group) and ($consul::install_method != 'docker' ) {
    group { $consul::group_real:
      ensure => 'present',
      system => true,
    }
  }
}
