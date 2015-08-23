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
  $port_hash = undef,
) {
  $port_hash_default = {
    'dns'      => 8600,
    'http'     => 8500,
    'https'    => -1,
    'rpc'      => 8400,
    'serf_lan' => 8301,
    'serf_wan' => 8302,
    'server'   => 8300,
  }
  $config_ports_not_int = merge($port_hash_default, $port_hash)
  $config_ports={
    'dns'      => $config_ports_not_int['dns'] * 1,
    'http'     => $config_ports_not_int['http'] * 1,
    'https'    => $config_ports_not_int['https'] * 1,
    'rpc'      => $config_ports_not_int['rpc'] * 1,
    'serf_lan' => $config_ports_not_int['serf_lan'] * 1,
    'serf_wan' => $config_ports_not_int['serf_wan'] * 1,
    'server'   => $config_ports_not_int['server'] * 1,
  }
  validate_hash($config_ports)
  if $consul::init_style {

    case $consul::init_style {
      'upstart' : {
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
      'systemd' : {
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

  file { $consul::config_dir:
    ensure  => 'directory',
    purge   => $purge,
    recurse => $purge,
  } ->
  file { 'consul config.json':
    ensure  => present,
    path    => "${consul::config_dir}/config.json",
    content => consul_sorted_json($config_hash, $consul::pretty_config, $consul::pretty_config_indent),
  }

}
