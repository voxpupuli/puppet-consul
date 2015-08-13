# == Class consul::intall
#
# Installs consule based in the parameters from init
#
class consul::install {

  if $consul::data_dir {
    file { $consul::data_dir:
      ensure => 'directory',
      owner  => $consul::user,
      group  => $consul::group,
      mode   => '0755',
    }
  }

  case $consul::install_method {
    'url': {
      # This is done just so we can take a look at what staging path it wants to use.
      # If we remove this, we have to completely assume or manage the staging path
      include staging

      if $::operatingsystem != 'darwin' {
        ensure_packages(['unzip'], { 'before' => Staging::File[$consul::real_download_file] })
      }

      ## Suggest moving to using puppetlabs-transition module to do the service work
      ##  after it gets some patchwork and closer to release version
      #
      # This was done for puppet 3.x not supporting Ubuntu 15 and Fedora 22, and since this ruby line doesn't support site.pp... override of Service { provider => 'systemd' }
      if $::puppetversion =~ /^4/ {
        $ruby_service_stop = $::operatingsystem ? {
          'fedora' => "ruby -r 'puppet' -e \"Puppet::Type.type(:service).newservice(:name => 'consul', :provider => '${consul::init_style}').provider.send('stop')\"",
          'ubuntu' => "ruby -r 'puppet' -e \"Puppet::Type.type(:service).newservice(:name => 'consul', :provider => '${consul::init_style}').provider.send('stop')\"",
          default  => "ruby -r 'puppet' -e \"Puppet::Type.type(:service).newservice(:name => 'consul').provider.send('stop')\""
        }
      } else {
        $ruby_service_stop = "ruby -r 'puppet' -e \"Puppet::Type.type(:service).newservice(:name => 'consul').provider.send('stop')\""
      }
      # I don't trust mistakes in $staging::path as if it was set to / then this find would delete everything except that one file all the way from the root path /
      # And since we're only supporting Linux and Darwin(Mac) in this current revision of this puppet-consul module.
      # This cleans all files in the staging folder except this specific file
      if $staging::path =~ /^\/opt\/staging.*/ {
        $clean_staging_dir = "find ${staging::path}/consul ! -name '${consul::real_download_file}' -type f -exec rm -f {} +"
      } else {
        $clean_staging_dir = "find /opt/staging/consul ! -name '${consul::real_download_file}' -type f -exec rm -f {} +"
      }
      staging::file { $consul::real_download_file:
        source => $consul::real_download_url
      } ->
      staging::extract { $consul::real_download_file:
        target => $consul::bin_dir,
        unless => "which consul > /dev/null ; if [ $? = 0 ]; then test `consul version | grep -m1 -o [0-9\\.] | tr -d '\\n'` = ${consul::version}; unlessval=$?; if [ \$unlessval = 1 ]; then ${clean_staging_dir}; ${ruby_service_stop}; rm -f ${consul::bin_dir}/consul; fi; else unlessval=1; fi; test \$unlessval = 0",
      } ->
      file { "${consul::bin_dir}/consul":
        owner => 'root',
        group => 0, # 0 instead of root because OS X uses "wheel".
        mode  => '0555',
      } ~> Class['consul::run_service']

      if ($consul::ui_dir and $consul::data_dir) {
        if $::operatingsystem != 'darwin' {
          Package['unzip'] -> Staging::Deploy['consul_web_ui.zip']
        }
        file { "${consul::data_dir}/${consul::version}_web_ui":
          ensure => 'directory',
          owner  => 'root',
          group  => 0, # 0 instead of root because OS X uses "wheel".
          mode   => '0755',
        } ->
        staging::deploy { 'consul_web_ui.zip':
          source  => $consul::real_ui_download_url,
          target  => "${consul::data_dir}/${consul::version}_web_ui",
          creates => "${consul::data_dir}/${consul::version}_web_ui/dist",
        } ->
        file { $consul::ui_dir:
          ensure => 'symlink',
          target => "${consul::data_dir}/${consul::version}_web_ui/dist",
        }
      }
    }
    'package': {
      package { $consul::package_name:
        ensure => $consul::package_ensure,
      }

      if $consul::ui_dir {
        package { $consul::ui_package_name:
          ensure  => $consul::ui_package_ensure,
          require => Package[$consul::package_name]
        }
      }

      if $consul::manage_user {
        User[$consul::user] -> Package[$consul::package_name]
      }

      if $consul::data_dir {
        Package[$consul::package_name] -> File[$consul::data_dir]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${consul::install_method} is invalid")
    }
  }

  if $consul::manage_user {
    user { $consul::user:
      ensure => 'present',
      system => true,
      groups => $consul::extra_groups,
    }

    if $consul::manage_group {
      Group[$consul::group] -> User[$consul::user]
    }
  }
  if $consul::manage_group {
    group { $consul::group:
      ensure => 'present',
      system => true,
    }
  }
}
