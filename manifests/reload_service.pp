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
  if $consul::manage_service == true and $consul::service_ensure == 'running' {
    exec { 'reload consul service':
      path        => [$consul::bin_dir,'/bin','/usr/bin'],
      command     => 'consul reload',
      environment => [
        "CONSUL_RPC_ADDR=${consul::rpc_addr}:${consul::rpc_port}",
      ],
      refreshonly => true,
    }
  }

}
