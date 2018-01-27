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
class consul::windows_service {

  $app_dir = regsubst($consul::bin_dir, '\/', '\\', 'G')
  $app_exec = "${app_dir}\\consul.exe"
  $agent_args = regsubst($consul::config_dir, '\/', '\\', 'G')
  $app_args = "agent -config-dir=${agent_args}"
  $app_log_path = "${app_dir}\\logs"
  $app_log_file = 'consul.log'
  $app_log = "${app_log_path}//${app_log_file}"

  include '::archive'

  file { $app_log_path:
    ensure => 'directory',
    owner  => 'Administrator',
    group  => 'Administrators',
    mode   => '0755',
  }
  -> exec { 'consul_service_install':
    cwd       => $consul::bin_dir,
    command   => "&'${consul::nssm_exec}' install Consul ${app_exec}",
    unless    => 'if((get-service -name consul -ErrorAction SilentlyContinue).count -ne 1){exit 1}',
    logoutput => true,
    provider  => 'powershell',
    notify    => Exec['consul_service_set_parameters']
  }
  file { "${consul::bin_dir}/set_service_parameters.ps1":
    ensure  => 'present',
    content => template('consul/set_service_parameters.ps1.erb'),
    notify  => Exec['consul_service_set_parameters']
  }
  -> exec { 'consul_service_set_parameters':
    cwd         => $consul::bin_dir,
    command     => "${consul::bin_dir}/set_service_parameters.ps1",
    refreshonly => true,
    logoutput   => true,
    provider    => 'powershell',
  }
}
