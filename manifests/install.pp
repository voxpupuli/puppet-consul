# == Class consul::intall
#
# Installs consule based in the parameters from init
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

  if $consul::install_method == 'url' {

    $base_dir = $consul::download_dir ? {
      undef   => $consul::bin_dir,
      default => $consul::download_dir
    }
    $download_dir = "${base_dir}/consul_${consul::version}_${consul::os}_${consul::arch}"

    if $::operatingsystem != 'darwin' {
      ensure_packages(['unzip'])
    }
    file { $download_dir:
      ensure => 'directory',
      owner  => $consul::user,
      group  => $consul::group,
      mode   => '0755',
    } ->
    staging::file { 'consul.zip':
      source => $consul::download_url
    } ->
    staging::extract { 'consul.zip':
      target  => $download_dir,
      creates => "${download_dir}/consul",
    } ->
    file { "${download_dir}/consul":
      owner => 'root',
      group => 0, # 0 instead of root because OS X uses "wheel".
      mode  => '0555',
    } ->
    file { "${consul::bin_dir}/consul":
      ensure => 'symlink',
      target => "${download_dir}/consul",
    }

    if ($consul::ui_dir and $consul::data_dir) {
      file { "${consul::data_dir}/${consul::version}_web_ui":
        ensure => 'directory',
        owner  => 'root',
        group  => 0, # 0 instead of root because OS X uses "wheel".
        mode   => '0755',
      } ->
      staging::deploy { 'consul_web_ui.zip':
        source  => $consul::ui_download_url,
        target  => "${consul::data_dir}/${consul::version}_web_ui",
        creates => "${consul::data_dir}/${consul::version}_web_ui/dist",
      }
      file { $consul::ui_dir:
        ensure => 'symlink',
        target => "${consul::data_dir}/${consul::version}_web_ui/dist",
      }
    }

  } elsif $consul::install_method == 'package' {

    package { $consul::package_name:
      ensure => $consul::package_ensure,
    }

    if $consul::ui_dir {
      package { $consul::ui_package_name:
        ensure => $consul::ui_package_ensure,
      }
    }

  } else {
    fail("The provided install method ${consul::install_method} is invalid")
  }

  if $consul::manage_user {
    user { $consul::user:
      ensure => 'present',
    }
  }
  if $consul::manage_group {
    group { $consul::group:
      ensure => 'present',
    }
  }
}
