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
    it { should contain_staging__file('consul.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/0.2.0_linux_amd64.zip') }
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

  context "By default, a user and group should be installed" do
    it { should contain_user('consul').with(:ensure => :present) }
    it { should contain_group('consul').with(:ensure => :present) }
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

  context "On a redhat-based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS'
    }}

    it { should contain_class('consul').with_init_style('redhat') }
    it { should contain_file('/etc/init.d/consul').with_content(/daemon --user=consul/) }
  end

  context "On hardy" do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :lsbdistrelease  => '8.04',
    }}

    it { should contain_class('consul').with_init_style('hardy') }
    it { should contain_file('/etc/init.d/consul').with_content(/start-stop-daemon .* \$DAEMON/) }
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
