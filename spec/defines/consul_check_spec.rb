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
  describe 'with interval' do
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
  describe 'with both ttl and interval' do
    let(:params) {{
      'ttl' => '30s',
      'interval' => '60s'
    }}
    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with both ttl and script' do
    let(:params) {{
      'ttl' => '30s',
      'script' => 'true'
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