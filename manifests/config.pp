#
# @summary This class is called from consul::init to install the config file.
#
# @param config_hash Hash for Consul to be deployed as JSON
# @param purge If set will make puppet remove stale config files.
# @param enable_beta_ui Should the UI be enabled
# @param allow_binding_to_root_ports Should binding to specified ports be allowed
# @param restart_on_change Should the service be restarted on changes
#
# @api private
class consul::config (
  Hash    $config_hash                 = $consul::config_hash_real,
  Boolean $purge                       = $consul::purge_config_dir,
  Boolean $enable_beta_ui              = $consul::enable_beta_ui,
  Boolean $allow_binding_to_root_ports = $consul::allow_binding_to_root_ports,
  Boolean $restart_on_change           = $consul::restart_on_change,
) {
  assert_private()
  $notify_service = $restart_on_change ? {
    true    => Class['consul::run_service'],
    default => undef,
  }

  if ($consul::init_style_real != 'unmanaged') {
    case $consul::init_style_real {
      'systemd': {
        $type = if ($config_hash['retry_join'] == undef or $config_hash['retry_join'].length < 2) {
          'simple'
        } else {
          'notify'
        }
        systemd::unit_file { 'consul.service':
          content => epp("${module_name}/consul.systemd.epp",
            {
              'user'                        => $consul::user,
              'group'                       => $consul::group,
              'bin_dir'                     => $consul::bin_dir,
              'config_dir'                  => $consul::config_dir,
              'extra_options'               => $consul::extra_options,
              'allow_binding_to_root_ports' => $allow_binding_to_root_ports,
              'enable_beta_ui'              => $enable_beta_ui,
              'type'                        => $type,
            }
          ),
          notify  => $notify_service,
        }
      }
      'sles': {
        file { '/etc/init.d/consul':
          ensure  => file,
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('consul/consul.sles.erb'),
        }
      }
      'launchd': {
        file { '/Library/LaunchDaemons/io.consul.daemon.plist':
          ensure  => file,
          mode    => '0644',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul/consul.launchd.erb'),
        }
      }
      'freebsd': {
        file { '/etc/rc.conf.d/consul':
          ensure  => file,
          mode    => '0444',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul/consul.freebsd-rcconf.erb'),
        }
        file { '/usr/local/etc/rc.d/consul':
          ensure  => file,
          mode    => '0555',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul/consul.freebsd.erb'),
        }
      }
      default: {
        fail("I don't know how to create an init script for style ${consul::init_style_real}")
      }
    }
  }

  file { $consul::config_dir:
    ensure  => 'directory',
    owner   => $consul::config_owner_real,
    group   => $consul::group_real,
    purge   => $purge,
    recurse => $purge,
  }

  file { 'consul config':
    ensure  => file,
    path    => "${consul::config_dir}/${consul::config_name}",
    owner   => $consul::config_owner_real,
    group   => $consul::group_real,
    mode    => $consul::config_mode,
    content => Sensitive(consul::sorted_json($config_hash, $consul::pretty_config, $consul::pretty_config_indent)),
  }
}
