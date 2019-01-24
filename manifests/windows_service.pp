# == Class consul::windows_service
#
# Installs consul windows server
# == Parameters
#
# [*nssm_version*]
#   nssm version to download
#
# [*nssm_download_url*]
#   nssm version to download
#
# [*nssm_download_url_base*]
#   nssm version to download
#
class consul::windows_service (
  $sys32 = 'c:\\windows\\system32',
  $service_name = 'Consul'
  )
{
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

