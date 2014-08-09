# == Class consul::intall
#
class consul::install {

  if $consul::data_dir {
    file { "${consul::data_dir}":
      ensure => 'directory',
      owner => $consul::user,
      group => $consul::group,
      mode  => '0755',
    }
  }

  if $consul::install_method == 'url' {

    ensure_packages(['unzip'])
    staging::file { 'consul.zip':
      source => $consul::download_url
    } ->
    staging::extract { 'consul.zip':
      target  => $consul::bin_dir,
      creates => "${consul::bin_dir}/consul",
    } ->
    file { "${consul::bin_dir}/consul":
      owner => 'root',
      group => 'root',
      mode  => '0555',
    }

    if ($consul::ui_dir and $consul::data_dir) {
      file { "${consul::data_dir}/${consul::version}_web_ui":
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      } ->
      staging::deploy { 'consul_web_ui.zip':
        source  => "${consul::ui_download_url}",
        target  => "${consul::data_dir}/${consul::version}_web_ui",
        creates => "${consul::data_dir}/${consul::version}_web_ui/dist",
      }
      file { "${consul::ui_dir}":
        ensure => 'symlink',
        target => "${consul::data_dir}/${consul::version}_web_ui/dist",
      }
    }

  } elsif $consul::install_method == 'package' {

    package { $consul::package_name:
      ensure => $consul::package_ensure,
    }

    if $consul::ui_package_name {
      package { $consul::ui_package_name:
        ensure => $consul::ui_package_ensure,
      }
    }

  } else {
    fail("The provided install method ${consul::install_method} is invalid")
  }

  case $consul::init_style {
    'upstart' : {
      file { '/etc/init/consul.conf':
        mode   => '0444',
        owner   => 'root',
        group   => 'root',
        content => template('consul/consul.upstart.erb'),
      }
    }
    'systemd' : {
      file { '/lib/systemd/system/consul.service':
        mode   => '0644',
        owner   => 'root',
        group   => 'root',
        content => template('consul/consul.systemd.erb'),
      }
    }
    'sysv' : {
      file { '/etc/init.d/consul':
        mode    => '0555',
        owner   => 'root',
        group   => 'root',
        content => template('consul/consul.sysv.erb')
      }
    }
    'debian' : {
      file { '/etc/init.d/consul':
        mode    => '0555',
        owner   => 'root',
        group   => 'root',
        content => template('consul/consul.debian.erb')
      }
    }
    default : {
      fail("I don't know how to create an init script for style $init_style")
    }
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
