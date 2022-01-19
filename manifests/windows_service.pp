# == Class consul::windows_service
#
# Installs consul windows server
# == Parameters
#
# [*service_name*]
#   Name of the service
#
class consul::windows_service (
  $service_name = 'Consul'
) {
  $executable_file = "${consul::bin_dir}\\${consul::binary_name}"
  $service_config = "start= auto binPath= \"${executable_file} agent -config-dir=${$consul::config_dir}\" obj= \"${consul::binary_owner}\""

  exec { 'create_consul_service':
    command => "sc.exe create ${service_name} ${service_config}",
    path    => $facts['system32'],
    unless  => "sc.exe query ${service_name}",
  }
  exec { 'update_consul_service':
    command     => "sc.exe config ${service_name} ${service_config}",
    path        => $facts['system32'],
    refreshonly => true,
  }
}
