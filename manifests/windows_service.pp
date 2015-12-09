class consul::windows_service(
  $service_name   = $consul::params::service_name,
  $package_target = $consul::params::package_target,
) {
  file { "${package_target}/scripts/do_windows_path.ps1":
    ensure  => 'present',
    content => template('consul/do_windows_path.ps1.erb'),
  } ->
  file { "${package_target}/scripts/make_service.ps1":
    ensure  => 'present',
    content => template('consul/make_service.ps1.erb'),
  } ->
  file { "${package_target}/helper/nssm.exe":
    ensure             => 'present',
    source             => "puppet:///modules/consul/nssm64/nssm.exe",
    source_permissions => 'ignore',
  } ->
# we must run path mods separately, because Windows shells do not self-update:
  exec { 'do_path':
    cwd         => "${package_target}/scripts",
    command     => "${package_target}/scripts/do_windows_path.ps1",
    subscribe   => File["${package_target}/scripts/do_windows_path.ps1"],
    refreshonly => true,
    provider    => 'powershell',
  }->
  exec { 'make_service':
    cwd         => "${package_target}/scripts",
    command     => "${package_target}/scripts/make_service.ps1",
    unless      => "get-service -name ${service_name}",
    subscribe   => File["${package_target}/scripts/make_service.ps1"],
    refreshonly => true,
    provider    => 'powershell',
  }->
  service { $service_name:
    ensure => "running",
  }

}