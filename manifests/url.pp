# == Class: consul::url
#
# Helper resource to install, upgrade and downgrade core and ui.
#
define consul::url (
  $url,
  $checksum,
  $extract_dir,
  $ensure   = present,
  $digest   = 'sha256',
  $timeout  = 60,
  $env_path = $::path,
  $tmp_dir  = '/tmp',
) {
  $package = $title

  Exec {
    path        => $env_path,
    refreshonly => true,
  }

  if $ensure =~ /^(present|installed)$/ {

    $package_name = "consul_${package}_${consul::version}"

    # We are assuming these are available on all systems
    case $digest {
      'md5','sha1','sha224','sha256','sha384','sha512' : { $checksum_bin = "${digest}sum" }
      default: { fail 'Unimplemented digest type' }
    }

    # Base packages
    if $::operatingsystem != 'darwin' and !defined(Package['unzip']) { ensure_packages(['unzip']) }
    if !defined(Package['curl']) { ensure_packages(['curl']) }

    file { "${consul::data_dir}/.version_${package}":
      ensure  => present,
      owner   => $consul::user,
      group   => $consul::group,
      mode    => '0644',
      content => "Managed by Puppet\n${package_name}\n",
      require => File[$consul::data_dir],
    } ~>
    exec { "Downloading package (${package_name})":
      command   => "curl -s -S -k -L -o ${tmp_dir}/${package_name}.zip '${url}'",
      logoutput => true,
      timeout   => $timeout,
      require   => Package['curl'],
    } ~>
    exec { "Adding ${digest} hash (${package_name})":
      command => "echo '${checksum} *${tmp_dir}/${package_name}.zip' > ${tmp_dir}/${package_name}_${digest}",
    } ~>
    exec { "Verifying ${digest} checksum (${package_name})":
      command => "echo 'checksum FAILED!' && rm -f ${consul::data_dir}/.version_${package} && exit 1",
      unless  => "${checksum_bin} --check --status ${tmp_dir}/${package_name}_${digest}",
    } ~>
    exec { "Extracting package (${package_name})":
      command => "unzip -o ${tmp_dir}/${package_name}.zip -d ${extract_dir}",
    } ~>
    exec { "Post install (${package_name})":
      command => "rm -f ${tmp_dir}/${package_name}.zip ${tmp_dir}/${package_name}_${digest}",
    }

    if $consul::restart_on_change {
      Exec["Extracting package (${package_name})"] ~> Class['consul::run_service']
    }

    if $package == 'core' {
      file { "${consul::bin_dir}/consul":
        ensure  => present,
        owner   => 'root',
        group   => 0, # 0 instead of root because OS X uses "wheel"
        mode    => '0555',
        require => Exec["Extracting package (${package_name})"],
      }
    } elsif ($package == 'ui' and $consul::ui_dir) {
      file { $consul::ui_dir:
        ensure  => 'symlink',
        target  => "${consul::data_dir}/dist",
        require => Exec["Extracting package (${package_name})"],
      }
    }

  } elsif $ensure =~ /^(absent|latest|purged)$/ {
    # TODO: https://github.com/solarkennedy/puppet-consul/issues/79
    notify { "${ensure} is not unsupported (${package})": }
  } else {
    notify { "Unknown ensure: ${ensure} (${package})": }
  }
}
