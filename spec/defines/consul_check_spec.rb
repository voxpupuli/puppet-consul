require 'spec_helper'

describe 'consul::check' do
  let(:facts) {{ :architecture => 'x86_64' }}
  let(:title) { "my_check" }

  describe 'with no args' do
    let(:params) {{}}

    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with script' do
    let(:params) {{
      'interval'    => '30s',
      'script' => 'true'
    }}
    it {
      should contain_file("/etc/consul/check_my_check.json") \
        .with_content(/"id" *: *"my_check"/)
        .with_content(/"name" *: *"my_check"/)
        .with_content(/"check" *: *{/)
        .with_content(/"interval" *: *"30s"/)
        .with_content(/"script" *: *"true"/)
    }
  end
  describe 'with script and service_id' do
    let(:params) {{
      'interval'    => '30s',
      'script' => 'true',
      'service_id' => 'my_service'
    }}
    it {
      should contain_file("/etc/consul/check_my_check.json") \
        .with_content(/"id" *: *"my_check"/)
        .with_content(/"name" *: *"my_check"/)
        .with_content(/"check" *: *{/)
        .with_content(/"interval" *: *"30s"/)
        .with_content(/"script" *: *"true"/)
        .with_content(/"service_id" *: *"my_service"/)
    }
  end
  describe 'with http' do
    let(:params) {{
      'interval'    => '30s',
      'http' => 'localhost'
    }}
    it {
      should contain_file("/etc/consul/check_my_check.json") \
        .with_content(/"id" *: *"my_check"/)
        .with_content(/"name" *: *"my_check"/)
        .with_content(/"check" *: *{/)
        .with_content(/"interval" *: *"30s"/)
        .with_content(/"http" *: *"localhost"/)
    }
  end
  describe 'with http and service_id' do
    let(:params) {{
      'interval'    => '30s',
      'http' => 'localhost',
      'service_id' => 'my_service'
    }}
    it {
      should contain_file("/etc/consul/check_my_check.json") \
        .with_content(/"id" *: *"my_check"/)
        .with_content(/"name" *: *"my_check"/)
        .with_content(/"check" *: *{/)
        .with_content(/"interval" *: *"30s"/)
        .with_content(/"http" *: *"localhost"/)
        .with_content(/"service_id" *: *"my_service"/)
    }
  end
  describe 'with http and removed undef values' do
    let(:params) {{
      'interval'    => '30s',
      'http' => 'localhost'
    }}
    it {
      should contain_file("/etc/consul/check_my_check.json") \
        .without_content(/"service_id"/)
        .without_content(/"notes"/)
    }
  end
  describe 'with ttl' do
    let(:params) {{
      'ttl' => '30s',
    }}
    it {
      should contain_file("/etc/consul/check_my_check.json") \
        .with_content(/"id" *: *"my_check"/)
        .with_content(/"name" *: *"my_check"/)
        .with_content(/"check" *: *{/)
        .with_content(/"ttl" *: *"30s"/)
    }
  end
  describe 'with ttl and service_id' do
    let(:params) {{
      'ttl' => '30s',
      'service_id' => 'my_service'
    }}
    it {
      should contain_file("/etc/consul/check_my_check.json") \
        .with_content(/"id" *: *"my_check"/)
        .with_content(/"name" *: *"my_check"/)
        .with_content(/"check" *: *{/)
        .with_content(/"ttl" *: *"30s"/)
        .with_content(/"service_id" *: *"my_service"/)
    }
  end
  describe 'with both ttl and interval' do
    let(:params) {{
      'ttl' => '30s',
      'interval' => '60s'
    }}
    it {
      should raise_error(Puppet::Error)
    }
  end
  describe 'with both ttl and script' do
    let(:params) {{
      'ttl' => '30s',
      'script' => 'true'
    }}
    it {
      should raise_error(Puppet::Error)
    }
  end
  describe 'with both ttl and http' do
    let(:params) {{
      'ttl' => '30s',
      'http' => 'http://localhost/health',
    }}
    it {
      should raise_error(Puppet::Error)
    }
  end
  describe 'with both script and http' do
    let(:params) {{
      'script' => 'true',
      'http' => 'http://localhost/health',
    }}
    it {
      should raise_error(Puppet::Error)
    }
  end
  describe 'with script but no interval' do
    let(:params) {{
      'script' => 'true',
    }}
    it {
      should raise_error(Puppet::Error)
    }
  end
  describe 'with http but no interval' do
    let(:params) {{
      'http' => 'http://localhost/health',
    }}
    it {
      should raise_error(Puppet::Error)
    }
  end
  describe 'with a / in the id' do
    let(:params) {{
      'ttl' => '30s',
      'service_id' => 'my_service',
      'id' => 'aa/bb',
    }}
    it { should contain_file("/etc/consul/check_aa_bb.json") \
        .with_content(/"id" *: *"aa\/bb"/)
    }
  end
end
