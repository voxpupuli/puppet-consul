# == Class consul::intall
#
class consul::install {

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

  } elsif $consul::install_method == 'package' {

    package { $consul::package_name:
      ensure => $consul::package_ensure,
    }

  } else {
    fail("The provided install method ${consul::install_method} is invalid")
  }

  file { '/etc/init/consul.conf':
    mode   => '0444',
    owner   => 'root',
    group   => 'root',
    content => template('consul/consul.upstart.erb'),
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
