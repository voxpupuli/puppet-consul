#
# @summary This class is meant to be called from certain configuration changes that support reload.
#
# @see https://www.consul.io/docs/agent/options.html#reloadable-configuration
# @api private
class consul::reload_service {
  assert_private()
  # Don't attempt to reload if we're not supposed to be running.
  # This can happen during pre-provisioning of a node.
  if $consul::manage_service == true and $consul::service_ensure == 'running' {
    if $consul::reload_command {
      $command = Sensitive($consul::reload_command)
    } else {
      $command_prefix = $consul::install_method ? {
        'docker' => 'docker exec -e CONSUL_HTTP_SSL_VERIFY=true consul consul reload',
        default  => 'consul reload',
      }
      $command = $consul::acl_api_token ? {
        ''      => "${command_prefix} ${consul::cli_options}",
        default => Sensitive("${command_prefix} ${consul::cli_options}"),
      }
    }

    exec { 'reload consul service':
      path        => [$consul::bin_dir,'/bin','/usr/bin'],
      environment => ['CONSUL_HTTP_SSL_VERIFY=true',],
      command     => $command,
      refreshonly => true,
      tries       => 3,
      try_sleep   => 10,
    }
  }
}
