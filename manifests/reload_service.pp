# == Class consul::reload_service
#
# This class is meant to be called from certain
# configuration changes that support reload.
#
# https://www.consul.io/docs/agent/options.html#reloadable-configuration
#
class consul::reload_service {

  # Don't attempt to reload if we're not supposed to be running.
  # This can happen during pre-provisioning of a node.
  if $::consul::manage_service == true and $::consul::service_ensure == 'running' {

    # Make sure we don't try to connect to 0.0.0.0, use 127.0.0.1 instead
    # This can happen if the consul agent RPC port is bound to 0.0.0.0
    if $::consul::rpc_addr == '0.0.0.0' {
      $rpc_addr = '127.0.0.1'
    } else {
      $rpc_addr = $::consul::rpc_addr
    }

    exec { 'reload consul service':
      path        => [$::consul::bin_dir,'/bin','/usr/bin'],
      command     => "consul reload -rpc-addr=${rpc_addr}:${consul::rpc_port}",
      refreshonly => true,
      tries       => 3,
    }
  }

}
