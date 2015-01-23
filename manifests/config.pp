# == Class consul::config
#
# This class is called from consul
#
class consul::config(
  $config_hash,
  $purge = true,
) {

  if $consul::init_style {

    case $consul::init_style {
      'upstart' : {
        file { '/etc/init/consul.conf':
          mode   => '0444',
          owner   => 'root',
          group   => 'root',
          content => template('consul/consul.upstart.erb'),
        }
        file { '/etc/init.d/consul':
          ensure => link,
          target => "/lib/init/upstart-job",
          owner  => root,
          group  => root,
          mode   => '0755',
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
      'sles' : {
        file { '/etc/init.d/consul':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('consul/consul.sles.erb')
        }
      }
      'launchd' : {
        file { '/Library/LaunchDaemons/io.consul.daemon.plist':
          mode    => '0644',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul/consul.launchd.erb')
        }
      }
      default : {
        fail("I don't know how to create an init script for style ${consul::init_style}")
      }
    }
  }

  # implicit conversion from string to int so it won't be quoted in JSON
  if has_key($config_hash, 'protocol') {
    $protocol_hash = {
      protocol => $config_hash['protocol'] * 1
    }
  } else {
    $protocol_hash = {}
  }

  # implicit conversion from string to int so it won't be quoted in JSON
  if has_key($config_hash, 'bootstrap_expect') {
    $bootstrap_expect_hash = {
      'bootstrap_expect' => $config_hash['bootstrap_expect'] * 1
    }
  } else {
    $bootstrap_expect_hash = {}
  }

  file { $consul::config_dir:
    ensure  => 'directory',
    purge   => $purge,
    recurse => $purge,
  } ->
  file { 'config.json':
    path    => "${consul::config_dir}/config.json",
    content => consul_sorted_json(merge($config_hash,$bootstrap_expect_hash,$protocol_hash)),
  }

}
