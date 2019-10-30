require 'spec_helper'

describe 'consul::service' do
  on_supported_os.each do |os, facts|
    next unless facts[:kernel] == 'Linux'
    context "on #{os} " do
      let :facts do
        facts
      end
      let(:title) { "my_service" }

      describe 'with no args' do
        let(:params) {{}}
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"service" *: *\{/) \
            .with_content(/"id" *: *"my_service"/) \
            .with_content(/"name" *: *"my_service"/) \
            .with_content(/"enable_tag_override" *: *false/)
        }
      end
      describe 'with no args ( consul version not less than 1.1.0 )' do
        let(:pre_condition) {
          'class { "consul": version => "1.1.0" }'
        }

        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"service" *: *\{/) \
            .with_content(/"id" *: *"my_service"/) \
            .with_content(/"name" *: *"my_service"/) \
            .with_content(/"enable_tag_override" *: *false/)
        }
      end
      describe 'with different ensure' do
        let(:params) {{
          'ensure' => 'absent',
        }}
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with('ensure' => 'absent')
        }
      end
      describe 'notify reload service' do
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .that_notifies('Class[consul::reload_service]')
        }
      end
      describe 'with service name' do
        let(:params) {{
          'service_name' => 'different_name',
        }}

        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"service" *: *\{/) \
            .with_content(/"id" *: *"my_service"/) \
            .with_content(/"name" *: *"different_name"/)
        }
      end
      describe 'with enable_tag_override' do
        let(:params) {{
          'enable_tag_override' => true,
        }}

        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"service" *: *\{/) \
            .with_content(/"id" *: *"my_service"/) \
            .with_content(/"name" *: *"my_service"/) \
            .with_content(/"enable_tag_override" *: *true/)
        }
      end
      describe 'with service name and address' do
        let(:params) {{
          'service_name' => 'different_name',
          'address' => '127.0.0.1',
        }}

        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"service" *: *\{/) \
            .with_content(/"id" *: *"my_service"/) \
            .with_content(/"name" *: *"different_name"/) \
            .with_content(/"address" *: *"127.0.0.1"/)
        }
      end
      describe 'with script and interval' do
        let(:params) {{
          'checks' => [
            {
              'interval'    => '30s',
              'script' => 'true'
            }
          ]
        }}
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"checks" *: *\[/) \
            .with_content(/"interval" *: *"30s"/) \
            .with_content(/"script" *: *"true"/)
        }
      end
      describe 'with http and interval' do
        let(:params) {{
          'checks' => [
            {
              'interval'    => '30s',
              'http' => 'localhost'
            }
          ]
        }}
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"checks" *: *\[/) \
            .with_content(/"interval" *: *"30s"/) \
            .with_content(/"http" *: *"localhost"/)
        }
      end
      describe 'with ttl' do
        let(:params) {{
          'checks' => [
            {
              'ttl'    => '30s',
            }
          ]
        }}
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"checks" *: *\[/) \
            .with_content(/"ttl" *: *"30s"/)
        }
      end
      describe 'with both ttl and interval' do
        let(:params) {{
          'checks' => [
            {
              'ttl'    => '30s',
              'interval'    => '30s',
            }
          ]
        }}
        it {
          expect {
            should raise_error(Puppet::Error, /script or http must not be defined for ttl checks/)
          }
        }
      end
      describe 'with port' do
        let(:params) {{
          'checks' => [
            {
              'ttl'    => '30s',
            }
          ],
          'port' => 5,
        }}
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"port":5/)
        }
        it {
          should_not contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"port":"5"/)
        }
      end
      describe 'with weight' do
        let(:params) {{
          'service_config_hash' => {
            'weights' => {
              'passing' => 10,
              'warning' => 1
            }
          }      
        }}
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"passing":10/)
        }
        it {
          should_not contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"passing":"10"/)
        }
      end
      describe 'with both ttl and script' do
        let(:params) {{
          'checks' => [
            {
              'ttl'    => '30s',
              'script' => 'true'
            }
          ]
        }}
        it {
          expect {
            should raise_error(Puppet::Error, /script or http must not be defined for ttl checks/)
          }
        }
      end
      describe 'with interval but no script' do
        let(:params) {{
          'checks' => [
            {
              'interval'    => '30s',
            }
          ]
        }}
        it {
          expect {
            should raise_error(Puppet::Error, /One of ttl, script or http must be defined/)
          }
        }
      end
      describe 'with multiple checks script and http' do
        let(:params) {{
          'checks' => [
            {
              'interval'    => '30s',
              'script' => 'true'
            },
            {
              'interval'    => '10s',
              'http' => 'localhost'
            }
          ]
        }}
        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"checks" *: *\[/) \
            .with_content(/"interval" *: *"30s"/) \
            .with_content(/"script" *: *"true"/) \
            .with_content(/"interval" *: *"10s"/) \
            .with_content(/"http" *: *"localhost"/)
        }
      end
      describe 'with a / in the id' do
        let(:params) {{
          'id' => 'aa/bb',
        }}
        it { should contain_file("/etc/consul/service_aa_bb.json") \
            .with_content(/"id" *: *"aa\/bb"/)
        }
      end
      describe 'with multiple / in the id' do
        let(:params) {{
          'id' => 'aa/bb/cc',
        }}
        it { should contain_file("/etc/consul/service_aa_bb_cc.json") \
            .with_content(/"id" *: *"aa\/bb\/cc"/)
        }
      end

      describe 'with multiple checks script and invalid http' do
        let(:params) {{
          'checks' => [
            {
              'interval'    => '30s',
              'script' => 'true'
            },
            {
              'http' => 'localhost'
            }
          ]
        }}
        it {
          expect {
            should raise_error(Puppet::Error, /http must be defined for interval checks/)
          }
        }
      end
      describe 'with token' do
        let(:params) {{
          'token' => 'too-cool-for-this-service',
        }}

        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"token" *: *"too-cool-for-this-service"/)
        }
      end
      describe 'with meta' do
        let(:params) {{
          'meta' => {
            'foo' => 'bar',
          },
        }}

        it {
          should contain_file("/etc/consul/service_my_service.json") \
            .with_content(/"meta" *: *\{/) \
            .with_content(/"foo" *: *"bar"/)
        }
      end
    end
  end
end
