# == Class consul::install
#
# Installs consul based on the parameters from init
#
class consul::install {

  $real_data_dir = pick($consul::data_dir, $consul::config_hash[data_dir], $consul::config_defaults[data_dir])

  if $consul::manage_data_dir {
    file { $real_data_dir:
      ensure => 'directory',
      owner  => $consul::user_real,
      group  => $consul::group_real,
      mode   => $consul::data_dir_mode,
    }
  }

  # only notify if we are installing a new version (work around for switching
  # to archive module)
  if $facts['consul_version'] != $consul::version {
    $do_notify_service = Class['consul::run_service']
  } else {
    $do_notify_service = undef
  }

  case $consul::install_method {
    'docker': {
      # Do nothing as docker will install when run
    }
    'url': {
      $install_path = pick($consul::archive_path, "${real_data_dir}/archives")


      include archive

      file { [$install_path, "${install_path}/consul-${consul::version}"]:
        ensure => directory,
        owner  => $consul::binary_owner,
        group  => $consul::binary_group,
        mode   => $consul::binary_mode,
      }

      archive { "${install_path}/consul-${consul::version}.${consul::download_extension}":
        ensure       => present,
        source       => $consul::real_download_url,
        proxy_server => $consul::proxy_server,
        extract      => true,
        extract_path => "${install_path}/consul-${consul::version}",
        creates      => "${install_path}/consul-${consul::version}/${consul::binary_name}",
        require      => File["${install_path}/consul-${consul::version}"],
      }

      file { "${install_path}/consul-${consul::version}/${consul::binary_name}":
        owner   => $consul::binary_owner,
        group   => $consul::binary_group,
        mode    => $consul::binary_mode,
        require => Archive["${install_path}/consul-${consul::version}.${consul::download_extension}"],
      }

      file { "${consul::bin_dir}/${consul::binary_name}":
        ensure  => link,
        notify  => $do_notify_service,
        target  => "${install_path}/consul-${consul::version}/${consul::binary_name}",
        require => File["${install_path}/consul-${consul::version}/${consul::binary_name}"],
      }
    }
    'package': {
      package { $consul::package_name:
        ensure => $consul::package_ensure,
        notify => $do_notify_service,
      }

      if $consul::manage_user {
        User[$consul::user_real] -> Package[$consul::package_name]
      }

      if $consul::data_dir {
        Package[$consul::package_name] -> File[$real_data_dir]
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
