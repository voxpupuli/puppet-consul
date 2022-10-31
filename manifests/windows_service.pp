#
# @summary Installs consul windows server
#
# @param sys32 path to system32 folder
# @param service_name Name of the service
#
# @api private
#
class consul::windows_service (
  $sys32 = 'c:\\windows\\system32',
  $service_name = 'Consul'
) {
  assert_private()
  $executable_file = "${consul::bin_dir}\\${consul::binary_name}"
  $service_config = "start= auto binPath= \"${executable_file} agent -config-dir=${$consul::config_dir}\" obj= \"${consul::binary_owner}\""

  exec { 'create_consul_service':
    command => "sc.exe create ${service_name} ${service_config}",
    path    => $sys32,
    unless  => "sc.exe query ${service_name}",
  }
  exec { 'update_consul_service':
    command     => "sc.exe config ${service_name} ${service_config}",
    path        => $sys32,
    refreshonly => true,
  }
}
