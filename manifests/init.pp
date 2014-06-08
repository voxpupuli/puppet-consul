# == Class: consul
#
# Installs, configures, and manages consul
#
# === Parameters
#
# [*version*]
#   Specify version of consul binary to download.
#
# [*config_hash*]
#   Use this to populate the JSON config file for consul.
#
# [*install_method*]
#   Defaults to `url` but can be `package` if you want to install via a system package.
#
# [*package_name*]
#   Only valid when the install_method == package. Defaults to `consul`.
#
# [*package_ensure*]
#   Only valid when the install_method == package. Defaults to `present`.
#
class consul (
  $manage_user    = true,
  $user           = 'consul',
  $manage_group   = true,
  $group          = 'consul',
  $bin_dir        = '/usr/local/bin',
  $arch           = $consul::params::arch,
  $version        = $consul::params::version,
  $install_method = $consul::params::install_method,
  $download_url   = "https://dl.bintray.com/mitchellh/consul/${version}_linux_${arch}.zip",
  $package_name   = $consul::params::package_name,
  $package_ensure = $consul::params::package_ensure,
  $config_dir     = '/etc/consul',
  $config_hash    = {},
  $service_enable = true,
  $service_ensure = 'running',
) inherits consul::params {

  validate_bool($manage_user)
  validate_hash($config_hash)

  class { 'consul::install': } ->
  class { 'consul::config': } ~>
  class { 'consul::run_service': } ->
  Class['consul']

}
