# == Class consul::install
#
# Installs consul based on the parameters from init
#
class consul::install {

  if ($::consul::data_dir) and ($::consul::selected_install_method != 'docker') {
    file { $::consul::data_dir:
      ensure => 'directory',
      owner  => $::consul::user,
      group  => $::consul::group,
      mode   => '0755',
    }
  }

  if $::consul::selected_install_method == 'docker' {
    file { $::consul::config_dir:
      ensure  => 'directory',
      purge   => $purge,
      recurse => $purge,
    }
  }
  else {
    file { $::consul::config_dir:
      ensure  => 'directory',
      owner   => $::consul::user,
      group   => $::consul::group,
      purge   => $purge,
      recurse => $purge,
    }
  }

  case $::consul::selected_install_method {
    'docker': {
      if $::consul::http_addr == '0.0.0.0' {
        $http_addr = '127.0.0.1'
      } else {
        $http_addr = $::consul::http_addr
      }
      $server_mode = pick($::consul::config_hash[server], false)
      
      if $server_mode {
        $env = [ '\'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}\'', '\'CONSUL_ALLOW_PRIVILEGED_PORTS=\'']
        $command = "agent -server -client=${http_addr}:${consul::http_port}"
      }
      else {
        $env = [ '\'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}\'' ]
        $command = "agent -client=${http_addr}:${consul::http_port}"
      }

      # Docker Install
      docker::run { 'consul' :
        image   => "${consul::docker_image}:${consul::version}",
        net     => 'host',
        volumes => [ "${::consul::config_dir}:/consul/config" ],
        env     => $env,
        command => $command
      }

    }
    'url': {
      $install_prefix = pick($::consul::config_hash[data_dir], '/opt/consul')
      $install_path = pick($::consul::archive_path, "${install_prefix}/archives")

      # only notify if we are installing a new version (work around for switching to archive module)
      if getvar('::consul_version') != $::consul::version {
        $do_notify_service = $::consul::notify_service
      } else {
        $do_notify_service = undef
      }

      include '::archive'
      file { [
        $install_path,
        "${install_path}/consul-${consul::version}"]:
        ensure => directory,
        owner  => 'root',
        group  => 0, # 0 instead of root because OS X uses "wheel".
        mode   => '0555';
      }
      -> archive { "${install_path}/consul-${consul::version}.${consul::download_extension}":
        ensure       => present,
        source       => $::consul::real_download_url,
        proxy_server => $::consul::proxy_server,
        extract      => true,
        extract_path => "${install_path}/consul-${consul::version}",
        creates      => "${install_path}/consul-${consul::version}/consul",
      }
      -> file {
        "${install_path}/consul-${consul::version}/consul":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${consul::bin_dir}/consul":
          ensure => link,
          notify => $do_notify_service,
          target => "${install_path}/consul-${consul::version}/consul";
      }

      if ($::consul::ui_dir and $::consul::data_dir) {

        # The 'dist' dir was removed from the web_ui archive in Consul version 0.6.0
        if (versioncmp($::consul::version, '0.6.0') < 0) {
          $archive_creates = "${install_path}/consul-${consul::version}_web_ui/dist"
          $ui_symlink_target = $archive_creates
        } else {
          $archive_creates = "${install_path}/consul-${consul::version}_web_ui/index.html"
          $ui_symlink_target = "${install_path}/consul-${consul::version}_web_ui"
        }

        file { "${install_path}/consul-${consul::version}_web_ui":
          ensure => directory,
        }
        -> archive { "${install_path}/consul_web_ui-${consul::version}.zip":
          ensure       => present,
          source       => $::consul::real_ui_download_url,
          proxy_server => $::consul::proxy_server,
          extract      => true,
          extract_path => "${install_path}/consul-${consul::version}_web_ui",
          creates      => $archive_creates,
        }
        ->file { $::consul::ui_dir:
          ensure => 'symlink',
          target => $ui_symlink_target,
        }
      }
    }
    'package': {
      package { $::consul::package_name:
        ensure => $::consul::package_ensure,
        notify => $::consul::notify_service
      }

      if $::consul::ui_dir {
        package { $::consul::ui_package_name:
          ensure  => $::consul::ui_package_ensure,
          require => Package[$::consul::package_name],
          notify  => $::consul::notify_service
        }
      }

      if $::consul::manage_user {
        User[$::consul::user] -> Package[$::consul::package_name]
      }

      if $::consul::data_dir {
        Package[$::consul::package_name] -> File[$::consul::data_dir]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${consul::install_method} is invalid")
    }
  }

  if ($::consul::manage_user) and ($::consul::selected_install_method != 'docker' ) {
    user { $::consul::user:
      ensure => 'present',
      system => true,
      groups => $::consul::extra_groups,
    }

    if ($::consul::manage_group) and ($::consul::selected_install_method != 'docker' ) {
      Group[$::consul::group] -> User[$::consul::user]
    }
  }
  if ($::consul::manage_group) and ($::consul::selected_install_method != 'docker' ) {
    group { $::consul::group:
      ensure => 'present',
      system => true,
    }
  }
}
