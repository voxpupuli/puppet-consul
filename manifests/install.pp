# == Class consul::install
#
# Installs consul using either url or system package.
#
class consul::install {

  if $consul::data_dir {
    file { $consul::data_dir:
      ensure => 'directory',
      owner  => $consul::user,
      group  => $consul::group,
      mode   => '0755',
    }
  }

  case $consul::install_method {
    'url': {

      consul::url { 'core':
        ensure      => $consul::core_package_ensure,
        url         => $consul::real_core_package_url,
        extract_dir => $consul::bin_dir,
        checksum    => $consul::core_package_checksum,
        digest      => $consul::url_digest,
        timeout     => $consul::url_timeout,
        env_path    => $consul::url_env_path,
        tmp_dir     => $consul::url_tmp_dir,
        require     => File[$consul::data_dir],
      }

      if $consul::ui_dir {
        consul::url { 'ui':
          ensure      => $consul::ui_package_ensure,
          url         => $consul::real_ui_package_url,
          extract_dir => $consul::data_dir,
          checksum    => $consul::ui_package_checksum,
          digest      => $consul::url_digest,
          timeout     => $consul::url_timeout,
          env_path    => $consul::url_env_path,
          tmp_dir     => $consul::url_tmp_dir,
          require     => [Consul::Url['core'], File[$consul::data_dir]],
        }
      }

    }
    'package': {
      package { $consul::core_package_name:
        ensure => $consul::core_package_ensure,
      }

      if $consul::ui_dir {
        package { $consul::ui_package_name:
          ensure  => $consul::ui_package_ensure,
          require => Package[$consul::core_package_name]
        }
      }

      if $consul::manage_user {
        User[$consul::user] -> Package[$consul::core_package_name]
      }

      if $consul::data_dir {
        Package[$consul::core_package_name] -> File[$consul::data_dir]
      }
    }
    'none': {
      #noop
    }
    default: {
      fail("The provided install method ${consul::install_method} is invalid")
    }
  }

  if $consul::manage_user {
    user { $consul::user:
      ensure => 'present',
      system => true,
      groups => $consul::extra_groups,
    }

    if $consul::manage_group {
      Group[$consul::group] -> User[$consul::user]
    }
  }
  if $consul::manage_group {
    group { $consul::group:
      ensure => 'present',
      system => true,
    }
  }
}
