class consul::windows_agent(
  $package_target = $consul::params::package_target,
  $executable     = $consul::params::executable,
  $package_name   = $consul::params::package_name,
  $version        = $consul::params::version,
# interpolated and assumed:
  $service_config = "${executable} agent -config-dir ${package_target}/config/' ",

) {

  file {[
    "${package_target}",
    "${package_target}/config",
    "${package_target}/data",
    "${package_target}/scripts",
    "${package_target}/helper",
    "${package_target}/logs",
  ]:
    ensure => 'directory',
  } ->
  file { "${package_target}/scripts/download_unpack.ps1":
    ensure  => 'present',
    content => template('consul/download_unpack.ps1.erb'),
  } ->
  exec { 'download_unpack':
    cwd         => $package_target,
    command     => "${package_target}/scripts/download_unpack.ps1",
    subscribe   => File["${package_target}/scripts/download_unpack.ps1"],
    refreshonly => true,
    logoutput   => true,
    provider    => 'powershell',
  }

}