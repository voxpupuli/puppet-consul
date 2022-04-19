require 'spec_helper'

describe 'consul::service' do
  on_supported_os.each do |os, facts|
    next unless facts[:kernel] == 'Linux'

    context "on #{os}" do
      let :facts do
        facts
      end
      let(:title) { 'my_service' }

      describe 'with no args' do
        let(:params) { {} }

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"service" *: *\{}). \
            with_content(%r{"id" *: *"my_service"}). \
            with_content(%r{"name" *: *"my_service"}). \
            with_content(%r{"enable_tag_override" *: *false})
        }
      end

      describe 'with no args ( consul version not less than 1.1.0 )' do
        let(:pre_condition) do
          'class { "consul": version => "1.1.0" }'
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"service" *: *\{}). \
            with_content(%r{"id" *: *"my_service"}). \
            with_content(%r{"name" *: *"my_service"}). \
            with_content(%r{"enable_tag_override" *: *false})
        }
      end

      describe 'with different ensure' do
        let(:params) do
          {
            'ensure' => 'absent',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with('ensure' => 'absent')
        }
      end

      describe 'notify reload service' do
        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            that_notifies('Class[consul::reload_service]')
        }
      end

      describe 'with service name' do
        let(:params) do
          {
            'service_name' => 'different_name',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"service" *: *\{}). \
            with_content(%r{"id" *: *"my_service"}). \
            with_content(%r{"name" *: *"different_name"})
        }
      end

      describe 'with enable_tag_override' do
        let(:params) do
          {
            'enable_tag_override' => true,
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"service" *: *\{}). \
            with_content(%r{"id" *: *"my_service"}). \
            with_content(%r{"name" *: *"my_service"}). \
            with_content(%r{"enable_tag_override" *: *true})
        }
      end

      describe 'with service name and address' do
        let(:params) do
          {
            'service_name' => 'different_name',
            'address' => '127.0.0.1',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"service" *: *\{}). \
            with_content(%r{"id" *: *"my_service"}). \
            with_content(%r{"name" *: *"different_name"}). \
            with_content(%r{"address" *: *"127.0.0.1"})
        }
      end

      describe 'with script and interval' do
        let(:params) do
          {
            'checks' => [
              {
                'interval' => '30s',
                'script' => 'true'
              },
            ]
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"checks" *: *\[}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"script" *: *"true"})
        }
      end

      describe 'with http and interval' do
        let(:params) do
          {
            'checks' => [
              {
                'interval' => '30s',
                'http' => 'localhost'
              },
            ]
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"checks" *: *\[}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"http" *: *"localhost"})
        }
      end

      describe 'with ttl' do
        let(:params) do
          {
            'checks' => [
              {
                'ttl' => '30s',
              },
            ]
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"checks" *: *\[}). \
            with_content(%r{"ttl" *: *"30s"})
        }
      end

      describe 'with both ttl and interval' do
        let(:params) do
          {
            'checks' => [
              {
                'ttl' => '30s',
                'interval' => '30s',
              },
            ]
          }
        end

        it {
          expect do
            is_expected.to raise_error(Puppet::Error, %r{script or http must not be defined for ttl checks})
          end
        }
      end

      describe 'with port' do
        let(:params) do
          {
            'checks' => [
              {
                'ttl' => '30s',
              },
            ],
            'port' => 5,
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"port":5})
        }

        it {
          is_expected.not_to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"port":"5"})
        }
      end

      describe 'with weight' do
        let(:params) do
          {
            'service_config_hash' => {
              'weights' => {
                'passing' => 10,
                'warning' => 1
              }
            }
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"passing":10})
        }

        it {
          is_expected.not_to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"passing":"10"})
        }
      end

      describe 'with both ttl and script' do
        let(:params) do
          {
            'checks' => [
              {
                'ttl' => '30s',
                'script' => 'true'
              },
            ]
          }
        end

        it {
          expect do
            is_expected.to raise_error(Puppet::Error, %r{script or http must not be defined for ttl checks})
          end
        }
      end

      describe 'with interval but no script' do
        let(:params) do
          {
            'checks' => [
              {
                'interval' => '30s',
              },
            ]
          }
        end

        it {
          expect do
            is_expected.to raise_error(Puppet::Error, %r{One of ttl, script or http must be defined})
          end
        }
      end

      describe 'with multiple checks script and http' do
        let(:params) do
          {
            'checks' => [
              {
                'interval' => '30s',
                'script' => 'true'
              },
              {
                'interval' => '10s',
                'http' => 'localhost'
              },
            ]
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"checks" *: *\[}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"script" *: *"true"}). \
            with_content(%r{"interval" *: *"10s"}). \
            with_content(%r{"http" *: *"localhost"})
        }
      end

      describe 'with a / in the id' do
        let(:params) do
          {
            'id' => 'aa/bb',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_aa_bb.json'). \
            with_content(%r{"id" *: *"aa/bb"})
        }
      end

      describe 'with multiple / in the id' do
        let(:params) do
          {
            'id' => 'aa/bb/cc',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_aa_bb_cc.json'). \
            with_content(%r{"id" *: *"aa/bb/cc"})
        }
      end

      describe 'with multiple checks script and invalid http' do
        let(:params) do
          {
            'checks' => [
              {
                'interval' => '30s',
                'script' => 'true'
              },
              {
                'http' => 'localhost'
              },
            ]
          }
        end

        it {
          expect do
            is_expected.to raise_error(Puppet::Error, %r{http must be defined for interval checks})
          end
        }
      end

      describe 'with token' do
        let(:params) do
          {
            'token' => 'too-cool-for-this-service',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"token" *: *"too-cool-for-this-service"})
        }
      end

      describe 'with meta' do
        let(:params) do
          {
            'meta' => {
              'foo' => 'bar',
            },
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/service_my_service.json'). \
            with_content(%r{"meta" *: *\{}). \
            with_content(%r{"foo" *: *"bar"})
        }
      end
    end
  end
end
