# == Class consul::install
#
# Installs consul based on the parameters from init
#
class consul::install {

  # need to deal with bin_dir creation ahead of download for Windows
  if $::operatingsystem == 'windows' {
    file {[
      "${consul::bin_dir}/",
      "${consul::bin_dir}/logs",
    ]:
      ensure => 'directory',
    }

    acl { "${consul::bin_dir}/":
      purge                        => true,
      inherit_parent_permissions => true,
    }

    if $consul::data_dir {
      file { $consul::data_dir:
        ensure => 'directory',
      }

      acl { "$consul::data_dir":
        purge       => true,
        inherit_parent_permissions => true,
      }
    }
  }

  else {
    if $consul::data_dir {
      file { $consul::data_dir:
        ensure => 'directory',
        owner  => $consul::user,
        group  => $consul::group,
        mode   => '0755',
      }
    }
  }

  $install_path = $::consul_downloaddir

  case $::operatingsystem {
    'windows': {
      $binary_name = 'consul.exe'
      $binary_owner = 'Administrators'
      $binary_group = 'Users'
    }
    default: {
      $binary_name = 'consul'
      $binary_owner = 'root'
      # 0 instead of root because OS X uses "wheel".
      $binary_group = 0
    }
  }

  case $consul::install_method {
    'url': {

      # only notify if we are installing a new version (work around for switching to archive module)
      if $::consul_version != $consul::version {
        $do_notify_service = $consul::notify_service
      } else {
        $do_notify_service = undef
      }

      include '::archive'
      file { [
        $install_path,
        "${install_path}/consul-${consul::version}"]:
        ensure => directory,
      }->
      archive { "${install_path}/consul-${consul::version}.${consul::download_extension}":
        ensure       => present,
        source       => $consul::real_download_url,
        extract      => true,
        extract_path => "${install_path}/consul-${consul::version}",
        creates      => "${install_path}/consul-${consul::version}/${binary_name}",
      }->
      file {  "${consul::bin_dir}/${$binary_name}":
          ensure => link,
          notify => $do_notify_service,
          target => "${install_path}/consul-${consul::version}/${$binary_name}";
      }

      if $::operatingsystem != 'windows' {
        file {
          "${install_path}/consul-${consul::version}/${$binary_name}":
            owner => $binary_owner,
            group => $binary_group,
            mode  => '0555';
        }
      }

      if ($consul::ui_dir and $consul::data_dir) {

        # The 'dist' dir was removed from the web_ui archive in Consul version 0.6.0
        if (versioncmp($::consul::version, '0.6.0') < 0) {
          $archive_creates = "${install_path}/consul-${consul::version}_web_ui/dist"
          $ui_symlink_target = $archive_creates
        } else {
          $archive_creates = "${install_path}/consul-${consul::version}_web_ui/index.html"
          $ui_symlink_target = "${install_path}/consul-${consul::version}_web_ui"
        }

        file { "${install_path}/consul-${consul::version}_web_ui":
          ensure => directory,
        }->
        archive { "${install_path}/consul_web_ui-${consul::version}.zip":
          ensure       => present,
          source       => $consul::real_ui_download_url,
          extract      => true,
          extract_path => "${install_path}/consul-${consul::version}_web_ui",
          creates      => $archive_creates,
        }->
        file { $consul::ui_dir:
          ensure => 'symlink',
          target => $ui_symlink_target,
        }
      }
    }
    'package': {
      package { $consul::package_name:
        ensure => $consul::package_ensure,
      }

      if $consul::ui_dir {
        package { $consul::ui_package_name:
          ensure  => $consul::ui_package_ensure,
          require => Package[$consul::package_name]
        }
      }

      if $consul::manage_user {
        User[$consul::user] -> Package[$consul::package_name]
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
