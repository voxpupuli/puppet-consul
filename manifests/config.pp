# == Class consul::config
#
# This class is called from consul
#
class consul::config(
  $config_hash,
  $purge = true,
) {

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
