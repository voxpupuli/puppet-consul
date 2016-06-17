class consul::windows_service(
  $nssm_version = '2.24',
  $nssm_download_url = undef,
  $nssm_download_url_base = 'https://nssm.cc/release',
) {

  $real_download_url = pick($nssm_download_url, "${nssm_download_url_base}/nssm-${nssm_version}.zip")

  $install_path = $::consul_downloaddir

  case $::architecture {
    'x32': {
      $nssm_exec = "${install_path}/nssm-${nssm_version}/win32/nssm.exe"
    }
    'x64': {
      $nssm_exec = "${install_path}/nssm-${nssm_version}/win64/nssm.exe"
    }
    default: {
      fail("Unknown architecture for windows - ${::architecture}")
    }
  }

  $app_dir = regsubst($consul::bin_dir, '\/', '\\', 'G')
  $app_exec = "${app_dir}\\consul.exe"
  $configdir_args = regsubst($consul::config_dir, '\/', '\\', 'G')
  $datadir_args = regsubst($consul::data_dir, '\/', '\\', 'G')
  $app_args = "agent -config-dir=${configdir_args} -data-dir=${datadir_args}"
  $app_log = "${app_dir}\\logs\\consul.log"

  include '::archive'
  archive { "${install_path}/nssm-${nssm_version}.zip":
    ensure       => present,
    source       => $real_download_url,
    extract      => true,
    extract_path => $install_path,
    creates      => [
      "${install_path}/nssm-${nssm_version}/win32/nssm.exe",
      "${install_path}/nssm-${nssm_version}/win64/nssm.exe",
    ],
  }->
  exec { 'consul_service_install':
    cwd       => $consul::bin_dir,
    command   => "${nssm_exec} install Consul \"${app_exec}\"",
    unless    => 'get-service -name consul',
    logoutput => true,
    provider  => 'powershell',
    notify    => Exec['consul_service_set_parameters']
  }->
  file { "${consul::bin_dir}/set_service_parameters.ps1":
    ensure  => 'present',
    content => template('consul/set_service_parameters.ps1.erb'),
    notify  => Exec['consul_service_set_parameters']
  } ->
  exec { 'consul_service_set_parameters':
    cwd         => $consul::bin_dir,
    command     => "& \"${consul::bin_dir}/set_service_parameters.ps1\"",
    refreshonly => true,
    logoutput   => true,
    provider    => 'powershell',
  }

}
