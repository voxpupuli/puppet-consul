require 'spec_helper'

describe 'consul::service' do
  let(:facts) {{ :architecture => 'x86_64' }}
  let(:title) { "my_service" }

  describe 'with no args' do
    let(:params) {{}}

    it {
      should contain_file("/etc/consul/service_my_service.json")
        .with_content(/"service" *: *{/)
        .with_content(/"id" *: *"my_service"/)
        .with_content(/"name" *: *"my_service"/)
    }
  end
  describe 'with service name' do
    let(:params) {{
      'service_name' => 'different_name',
    }}

    it {
      should contain_file("/etc/consul/service_my_service.json")
        .with_content(/"service" *: *{/)
        .with_content(/"id" *: *"my_service"/)
        .with_content(/"name" *: *"different_name"/)
    }
  end
  describe 'with interval' do
    let(:params) {{
      'check_interval'    => '30s',
      'check_script' => 'true'
    }}
    it {
      should contain_file("/etc/consul/service_my_service.json") \
        .with_content(/"check" *: *{/)
        .with_content(/"interval" *: *"30s"/)
        .with_content(/"script" *: *"true"/)
    }
  end
  describe 'with ttl' do
    let(:params) {{
      'check_ttl' => '30s',
    }}
    it {
      should contain_file("/etc/consul/service_my_service.json") \
        .with_content(/"check" *: *{/)
        .with_content(/"ttl" *: *"30s"/)
    }
  end
  describe 'with both ttl and interval' do
    let(:params) {{
      'check_ttl' => '30s',
      'check_interval' => '60s'
    }}
    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with port' do
    let(:params) {{
      'check_ttl' => '30s',
      'port' => 5,
    }}
    it { 
      should contain_file("/etc/consul/service_my_service.json")
        .with_content(/"port":5/)
    }
    it { 
      should_not contain_file("/etc/consul/service_my_service.json")
        .with_content(/"port":"5"/)
    }
  end
  describe 'with both ttl and script' do
    let(:params) {{
      'check_ttl' => '30s',
      'check_script' => 'true'
    }}
    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with interval but no script' do
    let(:params) {{
      'interval' => '30s',
    }}
    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
end
