require 'spec_helper'

describe 'consul' do

  RSpec.configure do |c|
    c.default_facts = {
      :architecture    => 'x86_64',
      :operatingsystem => 'Ubuntu',
      :lsbdistrelease  => '10.04',
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

  context 'When joining consul to a cluster by a known URL' do
    let(:params) {{
      :join_cluster => 'other_host.test.com'
    }}
    it { should contain_exec('join consul cluster').with(:command => 'consul join other_host.test.com') }
  end
  context 'By default, should not attempt to join a cluser' do
    it { should_not contain_exec('join consul cluster') }
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
    it { should contain_staging__file('consul.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/0.3.1_linux_amd64.zip') }
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
    it { should contain_staging__file('consul_web_ui.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/0.3.1_web_ui.zip') }
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
    it { should contain_file('config.json').with_content(/"bootstrap_expect": 5/) }
    it { should_not contain_file('config.json').with_content(/"bootstrap_expect": "5"/) }
  end

  context "When asked not to manage the user" do
    let(:params) {{ :manage_user => false }}
    it { should_not contain_user('consul') }
  end

  context "When asked not to manage the group" do
    let(:params) {{ :manage_group => false }}
    it { should_not contain_group('consul') }
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

  context "On a redhat 6 based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS',
      :operatingsystemmajrelease => 6,
    }}

    it { should contain_class('consul').with_init_style('sysv') }
    it { should contain_file('/etc/init.d/consul').with_content(/daemon --user=consul/) }
  end

  context "On a redhat 7 based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS',
      :operatingsystemmajrelease => 7,
    }}

    it { should contain_class('consul').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/consul.service').with_content(/consul agent/) }
  end

  context "On a fedora 20 based OS" do
    let(:facts) {{
      :operatingsystem => 'Fedora',
      :operatingsystemmajrelease => 20,
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
