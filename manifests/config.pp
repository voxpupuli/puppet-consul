# == Class consul::config
#
# This class is called from consul::init to install the config file.
#
# == Parameters
#
# [*config_hash*]
#   Hash for Consul to be deployed as JSON
#
# [*purge*]
#   Bool. If set will make puppet remove stale config files.
#
class consul::config(
  $config_hash,
  $purge = true,
) {

  if $::consul::init_style != 'unmanaged' {

    case $::consul::init_style {
      'upstart': {
        file { '/etc/init/consul.conf':
          mode    => '0444',
          owner   => 'root',
          group   => 'root',
          content => template('consul/consul.upstart.erb'),
        }
        file { '/etc/init.d/consul':
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd': {
        file { '/lib/systemd/system/consul.service':
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template('consul/consul.systemd.erb'),
        }~>
        exec { 'consul-systemd-reload':
          command     => 'systemctl daemon-reload',
          path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
          refreshonly => true,
        }
      }
      'init','redhat': {
        file { '/etc/init.d/consul':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('consul/consul.init.erb')
        }
      }
      'debian': {
        file { '/etc/init.d/consul':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('consul/consul.debian.erb')
        }
      }
      'sles': {
        file { '/etc/init.d/consul':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('consul/consul.sles.erb')
        }
      }
      'launchd': {
        file { '/Library/LaunchDaemons/io.consul.daemon.plist':
          mode    => '0644',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul/consul.launchd.erb')
        }
      }
      'freebsd': {
        file { '/etc/rc.conf.d/consul':
          mode    => '0444',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul/consul.freebsd-rcconf.erb')
        }
        file { '/usr/local/etc/rc.d/consul':
          mode    => '0555',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul/consul.freebsd.erb')
        }
      }
      default: {
        fail("I don't know how to create an init script for style ${consul::init_style}")
      }
    }
  }

  file { $::consul::config_dir:
    ensure  => 'directory',
    owner   => $::consul::user,
    group   => $::consul::group,
    purge   => $purge,
    recurse => $purge,
  } ->
  file { 'consul config.json':
    ensure  => present,
    path    => "${consul::config_dir}/config.json",
    owner   => $::consul::user,
    group   => $::consul::group,
    mode    => $::consul::config_mode,
    content => consul_sorted_json($config_hash, $::consul::pretty_config, $::consul::pretty_config_indent),
  }

}
