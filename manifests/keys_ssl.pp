class consul::keys_ssl (
  $package_target = $consul::params::package_target,
  $config_dir     = $consul::config_dir,
  $datacenter     = $::location,
  $environ        = $::product_line_environment,
) {

  if $::operatingsystem == 'windows' {
    $key_dir = "${package_target}/ssl"
  } else {
    $key_dir = "${config_dir}/ssl"
  }

#Oh lordy do we need a more secure way to store these keys...
  if $consul::do_ssl {
    file { $key_dir:
      ensure => 'directory',
    }
    file {"${key_dir}/ca.cert":
      ensure             => 'present',
      source             => "puppet:///modules/consul/agent_ssl/${environ}/ca.cert",
      source_permissions => 'ignore',
    }
    file {"${key_dir}/consul.cert":
      ensure             => 'present',
      source             => "puppet:///modules/consul/agent_ssl/${environ}/${datacenter}/consul.cert",
      source_permissions => 'ignore',
    }
    file {"${key_dir}/consul.key":
      ensure             => 'present',
      source             => "puppet:///modules/consul/agent_ssl/${environ}/${datacenter}/consul.key",
      source_permissions => 'ignore',
    }
  } else {
    warning('you have deliberately chosen to not use SSL keys.')
    warning('This is an insecure course of action.')
  }

}