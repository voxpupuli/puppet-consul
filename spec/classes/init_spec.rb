require 'spec_helper'

describe 'consul' do

  # Installation Stuff
  context 'On an unsupported arch' do
    let(:facts) {{ :architecture => 'bogus' }}
    let(:params) {{
      :install_method => 'package'
    }}
    it { expect { should compile }.to raise_error(/Unsupported kernel architecture:/) }
  end
  context 'When requesting to install via a package with defaults' do
    let(:facts) {{ :architecture => 'x86_64' }}
    let(:params) {{
      :install_method => 'package'
    }}
    it { should contain_package('consul').with(:ensure => 'latest') }
  end
  context 'When requesting to install via a custom package and version' do
    let(:facts) {{ :architecture => 'x86_64' }}
    let(:params) {{
      :install_method => 'package',
      :package_ensure => 'specific_release',
      :package_name   => 'custom_consul_package'
    }}
    it { should contain_package('custom_consul_package').with(:ensure => 'specific_release') }
  end
  context "When installing via URL by default" do
    let(:facts) {{ :architecture => 'x86_64' }}
    it { should contain_staging__file('consul.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/0.2.0_linux_amd64.zip') }
  end
  context "When installing via URL by with a special version" do
    let(:params) {{
      :version   => '42',
    }}
    let(:facts) {{ :architecture => 'x86_64' }}
    it { should contain_staging__file('consul.zip').with(:source => 'https://dl.bintray.com/mitchellh/consul/42_linux_amd64.zip') }
  end
  context "When installing via URL by with a custom url" do
    let(:facts) {{ :architecture => 'x86_64' }}
    let(:params) {{
      :download_url   => 'http://myurl',
    }}
    it { should contain_staging__file('consul.zip').with(:source => 'http://myurl') }
  end

  context "By default, a user and group should be installed" do
    let(:facts) {{ :architecture => 'x86_64' }}
    it { should contain_user('consul').with(:ensure => :present) }
    it { should contain_group('consul').with(:ensure => :present) }
  end
  context "When asked not to manage the user" do
    let(:facts) {{ :architecture => 'x86_64' }}
    let(:params) {{ :manage_user => false }}
    it { should_not contain_user('consul') }
  end
  context "When asked not to manage the group" do
    let(:facts) {{ :architecture => 'x86_64' }}
    let(:params) {{ :manage_group => false }}
    it { should_not contain_group('consul') }
  end
  context "With a custom username" do
    let(:facts) {{ :architecture => 'x86_64' }}
    let(:params) {{
      :user => 'custom_consul_user',
      :group => 'custom_consul_group',
    }}
    it { should contain_user('custom_consul_user').with(:ensure => :present) }
    it { should contain_group('custom_consul_group').with(:ensure => :present) }
    it { should contain_file('/etc/init/consul.conf').with_content(/sudo -u custom_consul_user -g custom_consul_group/) }
  end

  # Config Stuff

  # Service Stuff

end
