require 'spec_helper'

describe 'consul' do

  RSpec.configure do |c|
    c.default_facts = {
      :architecture           => 'x86_64',
      :operatingsystem        => 'Ubuntu',
      :osfamily               => 'Debian',
      :operatingsystemrelease => '10.04',
      :kernel                 => 'Linux',
      :ipaddress_lo           => '127.0.0.1',
      :consul_version         => 'unknown',
    }
  end
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
  # Installation Stuff
  context 'On an unsupported arch' do
    let(:facts) {{ :architecture => 'bogus' }}
    let(:params) {{
      :install_method => 'package'
    }}
    it { expect { should compile }.to raise_error(/Unsupported kernel architecture:/) }
  end

  context 'When not specifying whether to purge config' do
    it { should contain_file('/etc/consul').with(:purge => true,:recurse => true) }
  end

  context 'When passing a non-bool as purge_config_dir' do
    let(:params) {{
      :purge_config_dir => 'hello'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When passing a non-bool as manage_service' do
    let(:params) {{
      :manage_service => 'hello'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When disable config purging' do
    let(:params) {{
      :purge_config_dir => false
    }}
    it { should contain_class('consul::config').with(:purge => false) }
  end

  context 'consul::config should notify consul::run_service' do
    it { should contain_class('consul::config').that_notifies(['Class[consul::run_service]']) }
  end

  context 'consul::config should not notify consul::run_service on config change' do
    let(:params) {{
      :restart_on_change => false
    }}
    it { should_not contain_class('consul::config').that_notifies(['Class[consul::run_service]']) }
  end

  context 'When joining consul to a wan cluster by a known URL' do
    let(:params) {{
        :join_wan => 'wan_host.test.com'
    }}
    it { should contain_exec('join consul wan').with(:command => 'consul join -wan wan_host.test.com') }
  end

  context 'By default, should not attempt to join a wan cluster' do
    it { should_not contain_exec('join consul wan') }
  end

  context 'When requesting to install via a package with defaults' do
    let(:params) {{
      :install_method => 'package'
    }}
    it { should contain_package('consul').with(:ensure => 'latest') }
  end

  context 'When requesting to install via a custom package and version' do
    let(:params) {{
      :install_method => 'package',
      :package_ensure => 'specific_release',
      :package_name   => 'custom_consul_package'
    }}
    it { should contain_package('custom_consul_package').with(:ensure => 'specific_release') }
  end

  context "When installing via URL by default" do
    it { should contain_archive('/opt/consul/archives/consul-0.7.0.zip').with(:source => 'https://releases.hashicorp.com/consul/0.7.0/consul_0.7.0_linux_amd64.zip') }
    it { should contain_file('/opt/consul/archives').with(:ensure => 'directory') }
    it { should contain_file('/opt/consul/archives/consul-0.7.0').with(:ensure => 'directory') }
    it { should contain_file('/usr/local/bin/consul').that_notifies('Class[consul::run_service]') }
  end

  context "When installing via URL with a special archive_path" do
    let(:params) {{
      :archive_path   => '/usr/share/puppet-archive',
    }}
    it { should contain_archive('/usr/share/puppet-archive/consul-0.7.0.zip').with(:source => 'https://releases.hashicorp.com/consul/0.7.0/consul_0.7.0_linux_amd64.zip') }
    it { should contain_file('/usr/share/puppet-archive').with(:ensure => 'directory') }
    it { should contain_file('/usr/share/puppet-archive/consul-0.7.0').with(:ensure => 'directory') }
    it { should contain_file('/usr/local/bin/consul').that_notifies('Class[consul::run_service]') }
  end

  context "When installing by archive via URL and current version is already installed" do
    let(:facts) {{ :consul_version => '0.7.0' }}
    it { should contain_archive('/opt/consul/archives/consul-0.7.0.zip').with(:source => 'https://releases.hashicorp.com/consul/0.7.0/consul_0.7.0_linux_amd64.zip') }
    it { should contain_file('/usr/local/bin/consul') }
    it { should_not contain_notify(['Class[consul::run_service]']) }
  end

  context "When installing via URL by with a special version" do
    let(:params) {{
      :version   => '42',
    }}
    it { should contain_archive('/opt/consul/archives/consul-42.zip').with(:source => 'https://releases.hashicorp.com/consul/42/consul_42_linux_amd64.zip') }
    it { should contain_file('/usr/local/bin/consul').that_notifies('Class[consul::run_service]') }
  end

  context "When installing via URL by with a custom url" do
    let(:params) {{
      :download_url   => 'http://myurl',
    }}
    it { should contain_archive('/opt/consul/archives/consul-0.7.0.zip').with(:source => 'http://myurl') }
    it { should contain_file('/usr/local/bin/consul').that_notifies('Class[consul::run_service]') }
  end


  context 'When requesting to install via a package with defaults' do
    let(:params) {{
      :install_method => 'package'
    }}
    it { should contain_package('consul').with(:ensure => 'latest') }
  end

  context 'When requesting to install UI via a custom package and version' do
    let(:params) {{
      :install_method    => 'package',
      :ui_package_ensure => 'specific_ui_release',
      :ui_package_name   => 'custom_consul_ui_package',
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_package('custom_consul_ui_package').with(:ensure => 'specific_ui_release') }
  end

  context 'When requesting to not to install' do
    let(:params) {{
      :install_method => 'none'
    }}
    it { should_not contain_package('consul') }
    it { should_not contain_package('consul_ui') }
    it { should_not contain_staging__file('consul.zip') }
    it { should_not contain_staging__file('consul_web_ui-0.7.0.zip') }
  end

  context "When installing UI via URL by default" do
    let(:params) {{
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_archive('/dir1/archives/consul_web_ui-0.7.0.zip').with(:source => 'https://releases.hashicorp.com/consul/0.7.0/consul_0.7.0_web_ui.zip') }
    it { should contain_file('/dir1/dir2').that_requires('Archive[/dir1/archives/consul_web_ui-0.7.0.zip]') }
    it { should contain_file('/dir1/dir2').with(:ensure => 'symlink') }
  end

  context "When installing UI via URL with a special version" do
    let(:params) {{
      :version     => '42',
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_archive('/dir1/archives/consul_web_ui-42.zip').with(:source => 'https://releases.hashicorp.com/consul/42/consul_42_web_ui.zip') }
  end

  context "When installing UI via URL when version < 0.6.0" do
    let(:params) {{
      'version'    => '0.5.99',
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_archive('/dir1/archives/consul_web_ui-0.5.99.zip').with(:creates => %r{/dist$}) }
    it { should contain_file('/dir1/dir2').with(:target => %r{/dist$}) }
  end

  context "When installing UI via URL when version >= 0.6.0" do
    let(:params) {{
      'version'    => '0.6.0',
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_archive('/dir1/archives/consul_web_ui-0.6.0.zip').with(:creates => %r{/index\.html$}) }
    it { should contain_file('/dir1/dir2').with(:target => %r{_web_ui$}) }
  end

  context "When installing UI via URL by with a custom url" do
    let(:params) {{
      :ui_download_url => 'http://myurl',
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_archive('/dir1/archives/consul_web_ui-0.7.0.zip').with(:source => 'http://myurl') }
  end

  context "By default, a user and group should be installed" do
    it { should contain_user('consul').with(:ensure => :present) }
    it { should contain_group('consul').with(:ensure => :present) }
  end

  context "When data_dir is provided" do
    let(:params) {{
      :config_hash => {
        'data_dir' => '/dir1',
      },
    }}
    it { should contain_file('/dir1').with(:ensure => :directory) }
    it { should contain_file('/dir1/archives').with(:ensure => :directory) }
  end

  context "When data_dir not provided" do
    it { should_not contain_file('/dir1').with(:ensure => :directory) }
    it { should contain_file('/opt/consul/archives').with(:ensure => :directory) }
  end

  context "When ui_dir is provided but not data_dir" do
    let(:params) {{
      :config_hash => {
        'ui_dir' => '/dir1/dir2',
      },
    }}
    it { should_not contain_file('/dir1/dir2') }
  end

  context "When ui_dir and data_dir is provided" do
    let(:params) {{
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_file('/dir1') }
    it { should contain_file('/dir1/dir2') }
  end

  context 'The bootstrap_expect in config_hash is an int' do
    let(:params) {{
      :config_hash =>
        { 'bootstrap_expect' => '5' }
    }}
    it { should contain_file('consul config.json').with_content(/"bootstrap_expect":5/) }
    it { should_not contain_file('consul config.json').with_content(/"bootstrap_expect":"5"/) }
  end

  context 'Config_defaults is used to provide additional config' do
    let(:params) {{
      :config_defaults => {
          'data_dir' => '/dir1',
      },
      :config_hash => {
          'bootstrap_expect' => '5',
      }
    }}
    it { should contain_file('consul config.json').with_content(/"bootstrap_expect":5/) }
    it { should contain_file('consul config.json').with_content(/"data_dir":"\/dir1"/) }
  end

  context 'Config_defaults is used to provide additional config and is overridden' do
    let(:params) {{
      :config_defaults => {
          'data_dir' => '/dir1',
          'server' => false,
          'ports' => {
            'http' => 1,
            'rpc'  => '8300',
          },
      },
      :config_hash => {
          'bootstrap_expect' => '5',
          'server' => true,
          'ports' => {
            'http'  => -1,
            'https' => 8500,
          },
      }
    }}
    it { should contain_file('consul config.json').with_content(/"bootstrap_expect":5/) }
    it { should contain_file('consul config.json').with_content(/"data_dir":"\/dir1"/) }
    it { should contain_file('consul config.json').with_content(/"server":true/) }
    it { should contain_file('consul config.json').with_content(/"http":-1/) }
    it { should contain_file('consul config.json').with_content(/"https":8500/) }
    it { should contain_file('consul config.json').with_content(/"rpc":8300/) }
  end

  context 'When pretty config is true' do
    let(:params) {{
      :pretty_config => true,
      :config_hash => {
          'bootstrap_expect' => '5',
          'server' => true,
          'ports' => {
            'http'  => -1,
            'https' => 8500,
          },
      }
    }}
    it { should contain_file('consul config.json').with_content(/"bootstrap_expect": 5,/) }
    it { should contain_file('consul config.json').with_content(/"server": true/) }
    it { should contain_file('consul config.json').with_content(/"http": -1,/) }
    it { should contain_file('consul config.json').with_content(/"https": 8500/) }
    it { should contain_file('consul config.json').with_content(/"ports": \{/) }
  end

  context "When asked not to manage the user" do
    let(:params) {{ :manage_user => false }}
    it { should_not contain_user('consul') }
  end

  context "When asked not to manage the group" do
    let(:params) {{ :manage_group => false }}
    it { should_not contain_group('consul') }
  end

  context "When asked not to manage the service" do
    let(:params) {{ :manage_service => false }}

    it { should_not contain_service('consul') }
  end

  context "When a reload_service is triggered with service_ensure stopped" do
    let (:params) {{
      :service_ensure => 'stopped',
      :services => {
        'test_service1' => {
          'port' => '5'
        }
      }
    }}
    it { should_not contain_exec('reload consul service')  }
  end

  context "When a reload_service is triggered with manage_service false" do
    let (:params) {{
      :manage_service => false,
      :services => {
        'test_service1' => {
          'port' => '5'
        }
      }
    }}
    it { should_not contain_exec('reload consul service')  }
  end

  context "With a custom username" do
    let(:params) {{
      :user => 'custom_consul_user',
      :group => 'custom_consul_group',
    }}
    it { should contain_user('custom_consul_user').with(:ensure => :present) }
    it { should contain_group('custom_consul_group').with(:ensure => :present) }
    it { should contain_file('/etc/init/consul.conf').with_content(/env USER=custom_consul_user/) }
    it { should contain_file('/etc/init/consul.conf').with_content(/env GROUP=custom_consul_group/) }
  end

  context "Config with custom file mode" do
    let(:params) {{
      :user  => 'custom_consul_user',
      :group => 'custom_consul_group',
      :config_mode  => '0600',
    }}
    it { should contain_file('consul config.json').with(
      :owner => 'custom_consul_user',
      :group => 'custom_consul_group',
      :mode  => '0600'
    )}
  end

  context "When consul is reloaded" do
    let (:params) {{
      :services => {
        'test_service1' => {}
      }
    }}
    let (:facts) {{
      :ipaddress_lo => '127.0.0.1'
    }}
    it {
      should contain_exec('reload consul service').
        with_command('consul reload -rpc-addr=127.0.0.1:8400')
    }
  end

  context "When consul is reloaded on a custom port" do
    let (:params) {{
      :services => {
        'test_service1' => {}
      },
      :config_hash => {
        'ports' => {
          'rpc' => '9999'
        },
        'addresses' => {
          'rpc' => 'consul.example.com'
        }
      }
    }}
    it {
      should contain_exec('reload consul service').
        with_command('consul reload -rpc-addr=consul.example.com:9999')
    }
  end

  context "When consul is reloaded with a default client_addr" do
    let (:params) {{
      :services => {
        'test_service1' => {}
      },
      :config_hash => {
        'client_addr' => '192.168.34.56',
      }
    }}
    it {
      should contain_exec('reload consul service').
        with_command('consul reload -rpc-addr=192.168.34.56:8400')
    }
  end

  context "When the user provides a hash of services" do
    let (:params) {{
      :services => {
        'test_service1' => {
          'port' => '5'
        }
      }
    }}
    it { should contain_consul__service('test_service1').with_port('5') }
    it { should have_consul__service_resource_count(1) }
    it { should contain_exec('reload consul service')  }
  end

  context "When the user provides a hash of watches" do
    let (:params) {{
      :watches => {
        'test_watch1' => {
           'type'    => 'nodes',
           'handler' => 'test.sh',
        }
      }
    }}
    it { should contain_consul__watch('test_watch1').with_type('nodes') }
    it { should contain_consul__watch('test_watch1').with_handler('test.sh') }
    it { should have_consul__watch_resource_count(1) }
    it { should contain_exec('reload consul service')  }
  end

  context "When the user provides a hash of checks" do
    let (:params) {{
      :checks => {
        'test_check1' => {
          'interval' => '30',
          'script'   => 'test.sh',
        }
      }
    }}
    it { should contain_consul__check('test_check1').with_interval('30') }
    it { should contain_consul__check('test_check1').with_script('test.sh') }
    it { should have_consul__check_resource_count(1) }
    it { should contain_exec('reload consul service')  }
  end

  context "With multiple watches and a config hash for #83" do
    let (:params) {{
      :config_hash => {
        'data_dir'   => '/cust/consul',
        'datacenter' => 'devint',
        'log_level'  => 'INFO',
        'node_name'  => "${fqdn}"
      },
      :watches => {
        'services' => {
          'type'    => 'services',
          'handler' => 'sudo python /usr/local/bin/reacktor services'
        },
        'httpd_service' => {
          'type'    => 'service',
          'service' => 'httpd',
          'handler' => 'sudo python /usr/local/bin/reacktor service --service httpd'
        },
        'tomcat_service' => {
          'type'    => 'service',
          'service' => 'tomcat',
          'handler' => 'sudo python /usr/local/bin/reacktor service --service tomcat'
        }
      }
    }}
    it { should contain_consul__watch('services') }
    it { should have_consul__watch_resource_count(3) }
    it { should contain_exec('reload consul service')  }
  end

  context "When using init" do
    let (:params) {{
      :init_style => 'init'
    }}
    let (:facts) {{
      :ipaddress_lo => '127.0.0.1'
    }}
    it { should contain_class('consul').with_init_style('init') }
    it {
      should contain_file('/etc/init.d/consul').
        with_content(/-rpc-addr=127.0.0.1:8400/)
    }
  end

  context "When overriding default rpc port on init" do
    let (:params) {{
      :init_style => 'init',
      :config_hash => {
        'ports' => {
          'rpc' => '9999'
        },
        'addresses' => {
          'rpc' => 'consul.example.com'
        }
      }
    }}
    it { should contain_class('consul').with_init_style('init') }
    it {
      should contain_file('/etc/init.d/consul').
        with_content(/-rpc-addr=consul.example.com:9999/)
    }
  end

  context "When rpc_addr defaults to client_addr on init" do
    let (:params) {{
      :init_style => 'init',
      :config_hash => {
        'client_addr' => '192.168.34.56',
      }
    }}
    it { should contain_class('consul').with_init_style('init') }
    it {
      should contain_file('/etc/init.d/consul').
        with_content(/-rpc-addr=192.168.34.56:8400/)
    }
  end

  context "When using debian" do
    let (:params) {{
      :init_style => 'debian'
    }}
    let (:facts) {{
      :ipaddress_lo => '127.0.0.1'
    }}
    it { should contain_class('consul').with_init_style('debian') }
    it {
      should contain_file('/etc/init.d/consul').
        with_content(/-rpc-addr=127.0.0.1:8400/)
    }
  end

  context "When overriding default rpc port on debian" do
    let (:params) {{
      :init_style => 'debian',
      :config_hash => {
        'ports' => {
          'rpc' => '9999'
        },
        'addresses' => {
          'rpc' => 'consul.example.com'
        }
      }
    }}
    it { should contain_class('consul').with_init_style('debian') }
    it {
      should contain_file('/etc/init.d/consul').
        with_content(/-rpc-addr=consul.example.com:9999/)
    }
  end

  context "When using upstart" do
    let (:params) {{
      :init_style => 'upstart'
    }}
    let (:facts) {{
      :ipaddress_lo => '127.0.0.1'
    }}
    it { should contain_class('consul').with_init_style('upstart') }
    it {
      should contain_file('/etc/init/consul.conf').
        with_content(/-rpc-addr=127.0.0.1:8400/)
    }
  end

  context "When overriding default rpc port on upstart" do
    let (:params) {{
      :init_style => 'upstart',
      :config_hash => {
        'ports' => {
          'rpc' => '9999'
        },
        'addresses' => {
          'rpc' => 'consul.example.com'
        }
      }
    }}
    it { should contain_class('consul').with_init_style('upstart') }
    it {
      should contain_file('/etc/init/consul.conf').
        with_content(/-rpc-addr=consul.example.com:9999/)
    }
  end

  context "On a redhat 6 based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS',
      :operatingsystemrelease => '6.5'
    }}

    it { should contain_class('consul').with_init_style('redhat') }
    it { should contain_file('/etc/init.d/consul').with_content(/daemon --user=consul/) }
  end

  context "On an Archlinux based OS" do
    let(:facts) {{
      :operatingsystem => 'Archlinux',
    }}

    it { should contain_class('consul').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/consul.service').with_content(/consul agent/) }
  end

  context "On an Amazon based OS" do
    let(:facts) {{
      :operatingsystem => 'Amazon',
      :operatingsystemrelease => '3.10.34-37.137.amzn1.x86_64'
    }}

    it { should contain_class('consul').with_init_style('redhat') }
    it { should contain_file('/etc/init.d/consul').with_content(/daemon --user=consul/) }
  end

  context "On a redhat 7 based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS',
      :operatingsystemrelease => '7.0'
    }}

    it { should contain_class('consul').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/consul.service').with_content(/consul agent/) }
  end

  context "On a fedora 20 based OS" do
    let(:facts) {{
      :operatingsystem => 'Fedora',
      :operatingsystemrelease => '20'
    }}

    it { should contain_class('consul').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/consul.service').with_content(/consul agent/) }
  end

  context "On hardy" do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease  => '8.04',
    }}

    it { should contain_class('consul').with_init_style('debian') }
    it {
      should contain_file('/etc/init.d/consul') \
        .with_content(/start-stop-daemon .* \$DAEMON/) \
        .with_content(/DAEMON_ARGS="agent/) \
        .with_content(/--user \$USER/)
    }
  end

  context "On a Ubuntu Vivid 15.04 based OS" do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease => '15.04'
    }}

    it { should contain_class('consul').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/consul.service').with_content(/consul agent/) }
  end

  context "When asked not to manage the init system" do
    let(:params) {{ :init_style => 'unmanaged' }}
    it { should contain_class('consul').with_init_style('unmanaged') }
    it { should_not contain_file("/etc/init.d/consul") }
    it { should_not contain_file("/lib/systemd/system/consul.service") }
  end

  context "On squeeze" do
    let(:facts) {{
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '7.1'
    }}

    it { should contain_class('consul').with_init_style('debian') }
  end

  context "On opensuse" do
    let(:facts) {{
      :operatingsystem => 'OpenSuSE',
      :operatingsystemrelease => '13.1'
    }}

    it { should contain_class('consul').with_init_style('systemd') }
  end

  context "On SLED" do
    let(:facts) {{
      :operatingsystem => 'SLED',
      :operatingsystemrelease => '11.4'
    }}

    it { should contain_class('consul').with_init_style('sles') }
  end

  context "On SLES" do
    let(:facts) {{
      :operatingsystem => 'SLES',
      :operatingsystemrelease => '12.0'
    }}

    it { should contain_class('consul').with_init_style('systemd') }
  end

  # Config Stuff
  context "With extra_options" do
    let(:params) {{
      :extra_options => '-some-extra-argument'
    }}
    it { should contain_file('/etc/init/consul.conf').with_content(/\$CONSUL -S -- agent .*-some-extra-argument$/) }
  end
  # Service Stuff

end
