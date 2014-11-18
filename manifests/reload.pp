# == Class consul::reload
#
# This class is meant to be called from consul
# It will execute `consul reload`, useful for if a config file has changed.
#
class consul::reload {
  exec { 'consul reload':
    cwd         => $consul::config_dir,
    path        => [$consul::bin_dir, '/bin', '/usr/bin'],
    command     => 'consul reload',
    refreshonly => true,
  }
}
