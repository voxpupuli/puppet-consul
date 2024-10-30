require 'spec_helper'

describe 'consul' do
  on_supported_os.each do |os, os_facts|
    next unless os_facts[:kernel] == 'Linux'

    puts "on #{os}"
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('consul') }
      it { is_expected.to contain_class('consul::params') }
      it { is_expected.to contain_class('consul::run_service') }
      it { is_expected.to contain_class('consul::reload_service') }
      it { is_expected.to contain_class('consul::install') }
      it { is_expected.to contain_service('consul') }

      context 'When not specifying whether to purge config' do
        it { is_expected.to contain_file('/etc/consul').with(purge: true, recurse: true) }
      end

      context 'When disable config purging' do
        let(:params) do
          {
            purge_config_dir: false
          }
        end

        it { is_expected.to contain_class('consul::config').with(purge: false) }
      end

      context 'consul::config should notify consul::run_service' do
        it { is_expected.to contain_class('consul::config').that_notifies(['Class[consul::run_service]']) }
      end

      context 'consul::config should not notify consul::run_service on config change' do
        let(:params) do
          {
            restart_on_change: false
          }
        end

        it { is_expected.not_to contain_class('consul::config').that_notifies(['Class[consul::run_service]']) }
      end

      context 'When joining consul to a wan cluster by a known URL' do
        let(:params) do
          {
            join_wan: 'wan_host.test.com'
          }
        end

        it { is_expected.to contain_exec('join consul wan').with(command: 'consul join -wan wan_host.test.com') }
      end

      context 'By default, should not attempt to join a wan cluster' do
        it { is_expected.not_to contain_exec('join consul wan') }
      end

      context 'When asked not to manage the repo' do
        let(:params) do
          {
            manage_repo: false
          }
        end

        case os_facts[:os]['family']
        when 'Debian'
          it { is_expected.not_to contain_apt__source('HashiCorp') }
        when 'RedHat'
          it { is_expected.not_to contain_yumrepo('HashiCorp') }
        end
      end

      context 'When asked to manage the repo but not to install using package' do
        let(:params) do
          {
            install_method: 'url',
            manage_repo: true
          }
        end

        case os_facts[:os]['family']
        when 'Debian'
          it { is_expected.not_to contain_apt__source('HashiCorp') }
        when 'RedHat'
          it { is_expected.not_to contain_yumrepo('HashiCorp') }
        end
      end

      # hashicorp repo is not supported on Arch Linux/SLES
      context 'When asked to manage the repo and to install as package', unless: %w[Archlinux SLES Suse].include?(os_facts[:os]['family']) do
        let(:params) do
          {
            install_method: 'package',
            manage_repo: true
          }
        end

        case os_facts[:os]['family']
        when 'Debian'
          it { is_expected.to contain_apt__source('HashiCorp') }
        when 'RedHat'
          it { is_expected.to contain_yumrepo('HashiCorp') }
        end
        it { is_expected.to contain_file('/opt/consul').with_ensure('directory').that_requires('Package[consul]') }
        it { is_expected.to contain_package('consul').with(ensure: 'latest') }
      end

      context 'When asked to install as package and not to manage data_dir' do
        let(:params) do
          {
            install_method: 'package',
            manage_data_dir: false
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_file('/opt/consul').with_ensure('directory') }
      end

      context 'When requesting to install via a package with defaults' do
        let(:params) do
          {
            install_method: 'package'
          }
        end

        it { is_expected.to contain_package('consul').with(ensure: 'latest').that_notifies('Class[consul::run_service]') }
      end

      context 'When requesting to install via a custom package and version' do
        let(:params) do
          {
            install_method: 'package',
            package_ensure: 'specific_release',
            package_name: 'custom_consul_package'
          }
        end

        it { is_expected.to contain_package('custom_consul_package').with(ensure: 'specific_release') }
      end

      context 'When installing via URL by default' do
        it { is_expected.to contain_archive('/opt/consul/archives/consul-1.16.3.zip').with(source: 'https://releases.hashicorp.com/consul/1.16.3/consul_1.16.3_linux_amd64.zip') }
        it { is_expected.to contain_file('/opt/consul/archives').with(ensure: 'directory') }
        it { is_expected.to contain_file('/opt/consul/archives/consul-1.16.3').with(ensure: 'directory') }
        it { is_expected.to contain_file('/usr/local/bin/consul').that_notifies('Class[consul::run_service]') }
      end

      context 'When installing via URL with a special archive_path' do
        let(:params) do
          {
            archive_path: '/usr/share/puppet-archive',
          }
        end

        it { is_expected.to contain_archive('/usr/share/puppet-archive/consul-1.16.3.zip').with(source: 'https://releases.hashicorp.com/consul/1.16.3/consul_1.16.3_linux_amd64.zip') }
        it { is_expected.to contain_file('/usr/share/puppet-archive').with(ensure: 'directory') }
        it { is_expected.to contain_file('/usr/share/puppet-archive/consul-1.16.3').with(ensure: 'directory') }
        it { is_expected.to contain_file('/usr/local/bin/consul').that_notifies('Class[consul::run_service]') }
      end

      context 'When installing by archive via URL and current version is already installed' do
        let(:facts) do
          os_facts.merge({
                           consul_version: '1.16.3'
                         })
        end

        it { is_expected.to contain_archive('/opt/consul/archives/consul-1.16.3.zip').with(source: 'https://releases.hashicorp.com/consul/1.16.3/consul_1.16.3_linux_amd64.zip') }
        it { is_expected.to contain_file('/usr/local/bin/consul') }
        it { is_expected.not_to contain_notify(['Class[consul::run_service]']) }
      end

      context 'When installing via URL by with a special version' do
        let(:params) do
          {
            version: '42',
          }
        end

        it { is_expected.to contain_archive('/opt/consul/archives/consul-42.zip').with(source: 'https://releases.hashicorp.com/consul/42/consul_42_linux_amd64.zip') }
        it { is_expected.to contain_file('/usr/local/bin/consul').that_notifies('Class[consul::run_service]') }
      end

      context 'When installing via URL by with a custom url' do
        let(:params) do
          {
            download_url: 'http://myurl',
          }
        end

        it { is_expected.to contain_archive('/opt/consul/archives/consul-1.16.3.zip').with(source: 'http://myurl') }
        it { is_expected.to contain_file('/usr/local/bin/consul').that_notifies('Class[consul::run_service]') }
      end

      context 'When requesting to install via a package with defaults' do
        let(:params) do
          {
            install_method: 'package'
          }
        end

        it { is_expected.to contain_package('consul').with(ensure: 'latest') }
      end

      context 'When requesting to not to install' do
        let(:params) do
          {
            install_method: 'none'
          }
        end

        it { is_expected.not_to contain_package('consul') }
        it { is_expected.not_to contain_staging__file('consul.zip') }
      end

      context 'When installing UI' do
        let(:params) do
          {
            config_hash: {
              'ui' => true
            },
          }
        end

        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"ui":true})) }
      end

      context 'When not installing UI' do
        let(:params) do
          {
            config_hash: {},
          }
        end

        it { is_expected.not_to contain_file('consul config').with_content(sensitive(%r{"ui":true})) }
      end

      context 'By default, a user and group should be installed' do
        it { is_expected.to contain_user('consul').with(ensure: :present).without_uid.without_comment }
        it { is_expected.to contain_group('consul').with(ensure: :present) }
      end

      context 'When the user home directory location is not managed, a user should be created without the home parameter' do
        let(:params) do
          {
            manage_user_home_location: false,
          }
        end

        it { is_expected.to contain_user('consul').with(ensure: :present).without_home }
      end

      context 'with uid and comment and gid' do
        let :params do
          {
            uid: 2,
            comment: 'this is a comment',
            gid: 3,
          }
        end

        it { is_expected.to contain_user('consul').with(ensure: :present).with_uid(2).with_comment('this is a comment') }
        it { is_expected.to contain_group('consul').with(ensure: :present).with_gid(3) }
      end

      context 'When data_dir is provided' do
        let(:params) do
          {
            config_hash: {
              'data_dir' => '/dir1',
            },
          }
        end

        it { is_expected.to contain_file('/dir1').with(ensure: :directory) }
        it { is_expected.to contain_file('/dir1/archives').with(ensure: :directory) }
      end

      context 'When data_dir not provided' do
        it { is_expected.not_to contain_file('/dir1').with(ensure: :directory) }
        it { is_expected.to contain_file('/opt/consul/archives').with(ensure: :directory) }
      end

      context 'The bootstrap_expect in config_hash is an int' do
        let(:params) do
          {
            config_hash: { 'bootstrap_expect' => '5' }
          }
        end

        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"bootstrap_expect":5})) }
        it { is_expected.not_to contain_file('consul config').with_content(sensitive(%r{"bootstrap_expect":"5"})) }
      end

      context 'Config_defaults is used to provide additional config' do
        let(:params) do
          {
            config_defaults: {
              'data_dir' => '/dir1',
            },
            config_hash: {
              'bootstrap_expect' => '5',
            }
          }
        end

        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"bootstrap_expect":5})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"data_dir":"/dir1"})) }
      end

      context 'Config_defaults is used to provide additional config and is overridden' do
        let(:params) do
          {
            config_defaults: {
              'data_dir' => '/dir1',
              'server' => false,
              'ports' => {
                'http' => 1,
                'https' => '8300',
              },
            },
            config_hash: {
              'bootstrap_expect' => '5',
              'server' => true,
              'ports' => {
                'http' => -1,
                'https' => '8500',
              },
            }
          }
        end

        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"bootstrap_expect":5})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"data_dir":"/dir1"})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"server":true})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"http":-1})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"https":8500})) }
      end

      context 'When pretty config is true' do
        let(:params) do
          {
            pretty_config: true,
            config_hash: {
              'bootstrap_expect' => '5',
              'server' => true,
              'ports' => {
                'http' => -1,
                'https' => 8500,
              },
            }
          }
        end

        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"bootstrap_expect": 5,})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"server": true})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"http": -1,})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"https": 8500})) }
        it { is_expected.to contain_file('consul config').with_content(sensitive(%r{"ports": \{})) }
      end

      context 'When asked not to manage the user' do
        let(:params) { { manage_user: false } }

        it { is_expected.not_to contain_user('consul') }
      end

      context 'When asked not to manage the group' do
        let(:params) { { manage_group: false } }

        it { is_expected.not_to contain_group('consul') }
      end

      context 'When asked not to manage the service' do
        let(:params) { { manage_service: false } }

        it { is_expected.not_to contain_service('consul') }
      end

      context 'When a reload_service is triggered with service_ensure stopped' do
        let(:params) do
          {
            service_ensure: 'stopped',
            services: {
              'test_service1' => {
                'port' => 8088
              }
            }
          }
        end

        it { is_expected.not_to contain_exec('reload consul service') }
      end

      context 'When a reload_service is triggered with manage_service false' do
        let(:params) do
          {
            manage_service: false,
            services: {
              'test_service1' => {
                'port' => 8088
              }
            }
          }
        end

        it { is_expected.not_to contain_exec('reload consul service') }
      end

      context 'With a custom username' do
        let(:params) do
          {
            user: 'custom_consul_user',
            group: 'custom_consul_group',
          }
        end

        it { is_expected.to contain_user('custom_consul_user').with(ensure: :present) }
        it { is_expected.to contain_group('custom_consul_group').with(ensure: :present) }
      end

      context 'Config with custom file mode' do
        let(:params) do
          {
            user: 'custom_consul_user',
            group: 'custom_consul_group',
            config_mode: '0600',
          }
        end

        it {
          is_expected.to contain_file('consul config').with(
            owner: 'custom_consul_user',
            group: 'custom_consul_group',
            mode: '0600'
          )
        }
      end

      context 'Config with custom config owner' do
        let(:params) do
          {
            config_owner: 'custom_consul_user',
            config_dir: '/etc/custom_consul_dir',
          }
        end

        it { is_expected.to contain_file('consul config').with(owner: 'custom_consul_user') }
        it { is_expected.to contain_file('/etc/custom_consul_dir').with(owner: 'custom_consul_user') }
      end

      context 'When consul is reloaded' do
        let(:params) do
          {
            services: {
              'test_service1' => {}
            }
          }
        end

        it {
          is_expected.to contain_exec('reload consul service').
            with_command('consul reload -http-addr=127.0.0.1:8500')
        }
      end

      context 'When consul is reloaded on a custom port' do
        let(:params) do
          {
            services: {
              'test_service1' => {}
            },
            config_hash: {
              'ports' => {
                'http' => 9999
              },
              'addresses' => {
                'http' => 'consul.example.com'
              }
            }
          }
        end

        it {
          is_expected.to contain_exec('reload consul service').
            with_command('consul reload -http-addr=consul.example.com:9999')
        }
      end

      context 'When consul is reloaded with a default client_addr' do
        let(:params) do
          {
            services: {
              'test_service1' => {}
            },
            config_hash: {
              'client_addr' => '192.168.34.56',
            }
          }
        end

        it {
          is_expected.to contain_exec('reload consul service').
            with_command('consul reload -http-addr=192.168.34.56:8500')
        }
      end

      context 'When the user provides a hash of services' do
        let(:params) do
          {
            services: {
              'test_service1' => {
                'port' => 8088
              }
            }
          }
        end

        it { is_expected.to contain_consul__service('test_service1').with_port(8088) }
        it { is_expected.to have_consul__service_resource_count(1) }
        it { is_expected.to contain_exec('reload consul service')  }
      end

      context 'When the user provides a hash of watches' do
        let(:params) do
          {
            watches: {
              'test_watch1' => {
                'type' => 'nodes',
                'handler' => 'test.sh',
              }
            }
          }
        end

        it { is_expected.to contain_consul__watch('test_watch1').with_type('nodes') }
        it { is_expected.to contain_consul__watch('test_watch1').with_handler('test.sh') }
        it { is_expected.to have_consul__watch_resource_count(1) }
        it { is_expected.to contain_exec('reload consul service') }
      end

      context 'When the user provides a hash of checks' do
        let(:params) do
          {
            checks: {
              'test_check1' => {
                'interval' => '30',
                'script' => 'test.sh',
              }
            }
          }
        end

        it { is_expected.to contain_consul__check('test_check1').with_interval('30') }
        it { is_expected.to contain_consul__check('test_check1').with_script('test.sh') }
        it { is_expected.to have_consul__check_resource_count(1) }
        it { is_expected.to contain_exec('reload consul service') }
      end

      context 'With multiple watches and a config hash for #83' do
        let(:params) do
          {
            config_hash: {
              'data_dir' => '/cust/consul',
              'datacenter' => 'devint',
              'log_level' => 'INFO',
              'node_name' => '${fqdn}'
            },
            watches: {
              'services' => {
                'type' => 'services',
                'handler' => 'sudo python /usr/local/bin/reacktor services'
              },
              'httpd_service' => {
                'type' => 'service',
                'service' => 'httpd',
                'handler' => 'sudo python /usr/local/bin/reacktor service --service httpd'
              },
              'tomcat_service' => {
                'type' => 'service',
                'service' => 'tomcat',
                'handler' => 'sudo python /usr/local/bin/reacktor service --service tomcat'
              }
            }
          }
        end

        it { is_expected.to contain_consul__watch('services') }
        it { is_expected.to have_consul__watch_resource_count(3) }
        it { is_expected.to contain_exec('reload consul service') }
      end

      context 'When asked not to manage the init system' do
        let(:params) { { init_style: 'unmanaged' } }

        it { is_expected.to contain_class('consul').with_init_style('unmanaged') }
        it { is_expected.not_to contain_file('/etc/init.d/consul') }
        it { is_expected.not_to contain_file('/etc/systemd/system/consul.service') }
      end

      case os_facts[:os]['family']
      when 'RedHat', 'Archlinux', 'Debian'
        context 'On a modern OS' do
          it { is_expected.to contain_class('consul').with_init_style('systemd') }
          it { is_expected.to contain_file('/etc/systemd/system/consul.service').with_content(%r{consul agent}) }
        end
      when 'OpenSuSE'
        context 'On opensuse' do
          it { is_expected.to contain_class('consul').with_init_style('systemd') }
        end

        context 'On SLED' do
          it { is_expected.to contain_class('consul').with_init_style('sles') }
        end

        context 'On SLES' do
          it { is_expected.to contain_class('consul').with_init_style('systemd') }
        end
      when 'FreeBSD'
        context 'On FreeBSD' do
          it { is_expected.to contain_file('/usr/local/etc/consul.d').with(purge: true, recurse: true) }
        end
      end
    end
  end
end
