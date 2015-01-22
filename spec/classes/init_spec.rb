require 'spec_helper'

describe 'consul' do

  RSpec.configure do |c|
    c.default_facts = {
      :architecture    => 'x86_64',
      :operatingsystem => 'Ubuntu',
      :lsbdistrelease  => '10.04',
      :kernel          => 'Linux',
    }
  end
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
    it { should contain_staging__file('consul.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip') }
  end

  context "When installing via URL by with a special version" do
    let(:params) {{
      :version   => '42',
    }}
    it { should contain_staging__file('consul.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/42_linux_amd64.zip') }
  end

  context "When installing via URL by with a custom url" do
    let(:params) {{
      :download_url   => 'http://myurl',
    }}
    it { should contain_staging__file('consul.zip').with(:source => 'http://myurl') }
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

  context "When installing UI via URL by default" do
    let(:params) {{
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_staging__file('consul_web_ui.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip') }
  end

  context "When installing UI via URL by with a special version" do
    let(:params) {{
      :version => '42',
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_staging__file('consul_web_ui.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/42_web_ui.zip') }
  end

  context "When installing UI via URL by with a custom url" do
    let(:params) {{
      :ui_download_url => 'http://myurl',
      :config_hash => {
        'data_dir' => '/dir1',
        'ui_dir'   => '/dir1/dir2',
      },
    }}
    it { should contain_staging__deploy('consul_web_ui.zip').with(:source => 'http://myurl') }
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
  end

  context "When data_dir not provided" do
    it { should_not contain_file('/dir1').with(:ensure => :directory) }
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
    it { should contain_file('config.json').with_content(/"bootstrap_expect":5/) }
    it { should_not contain_file('config.json').with_content(/"bootstrap_expect":"5"/) }
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
    it { should contain_file('config.json').with_content(/"bootstrap_expect":5/) }
    it { should contain_file('config.json').with_content(/"data_dir":"\/dir1"/) }
  end

  context 'Config_defaults is used to provide additional config and is overridden' do
    let(:params) {{
      :config_defaults => {
          'data_dir' => '/dir1',
          'server' => false,
      },
      :config_hash => {
          'bootstrap_expect' => '5',
          'server' => true,
      }
    }}
    it { should contain_file('config.json').with_content(/"bootstrap_expect":5/) }
    it { should contain_file('config.json').with_content(/"data_dir":"\/dir1"/) }
    it { should contain_file('config.json').with_content(/"server":true/) }
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

  context "With a custom username" do
    let(:params) {{
      :user => 'custom_consul_user',
      :group => 'custom_consul_group',
    }}
    it { should contain_user('custom_consul_user').with(:ensure => :present) }
    it { should contain_group('custom_consul_group').with(:ensure => :present) }
    it { should contain_file('/etc/init/consul.conf').with_content(/sudo -u custom_consul_user -g custom_consul_group/) }
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
  end

  context "When the user provides a hash of watches" do
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
  end

  context "On a redhat 6 based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS',
      :operatingsystemrelease => '6.5'
    }}

    it { should contain_class('consul').with_init_style('sysv') }
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
      :lsbdistrelease  => '8.04',
    }}

    it { should contain_class('consul').with_init_style('debian') }
    it {
      should contain_file('/etc/init.d/consul')
        .with_content(/start-stop-daemon .* \$DAEMON/)
        .with_content(/DAEMON_ARGS="agent/)
        .with_content(/--user \$USER/)
    }
  end

  context "When asked not to manage the init_style" do
    let(:params) {{ :init_style => false }}
    it { should contain_class('consul').with_init_style(false) }
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

  # Config Stuff
  context "With extra_options" do
    let(:params) {{
      :extra_options => '-some-extra-argument'
    }}
    it { should contain_file('/etc/init/consul.conf').with_content(/\$CONSUL agent .*-some-extra-argument$/) }
  end
  # Service Stuff

end
