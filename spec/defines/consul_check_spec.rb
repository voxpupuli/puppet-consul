require 'spec_helper'

describe 'consul::check' do
  on_supported_os.each do |os, facts|
    next unless facts[:kernel] == 'Linux'

    context "on #{os}" do
      let :facts do
        facts
      end

      let(:title) { 'my_check' }

      describe 'with no args' do
        let(:params) { {} }

        it {
          expect do
            is_expected.to raise_error(Puppet::Error, %r{Wrong number of arguments})
          end
        }
      end

      describe 'with script' do
        let(:params) do
          {
            'interval' => '30s',
            'script' => 'true'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"script" *: *"true"})
        }
      end

      describe 'with args' do
        let(:params) do
          {
            'interval' => '30s',
            'args' => ['sh', '-c', 'true', '1', 2],
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"args" *: *\[ *"sh", *"-c", *"true", *"1", *"2" *\]})
        }
      end

      describe 'with script and service_id' do
        let(:params) do
          {
            'interval' => '30s',
            'script' => 'true',
            'service_id' => 'my_service'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"script" *: *"true"}). \
            with_content(%r{"service_id" *: *"my_service"})
        }
      end

      describe 'reload service with script and token' do
        let(:params) do
          {
            'interval' => '30s',
            'script' => 'true',
            'token' => 'too-cool-for-this-script'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"script" *: *"true"}). \
            with_content(%r{"token" *: *"too-cool-for-this-script"}). \
            that_notifies('Class[consul::reload_service]') \
        }
      end

      describe 'with http' do
        let(:params) do
          {
            'interval' => '30s',
            'http' => 'localhost'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"http" *: *"localhost"}) \
        }
      end

      describe 'with http and service_id' do
        let(:params) do
          {
            'interval' => '30s',
            'http' => 'localhost',
            'service_id' => 'my_service'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"http" *: *"localhost"}). \
            with_content(%r{"service_id" *: *"my_service"})
        }
      end

      describe 'reload service with http and token' do
        let(:params) do
          {
            'interval' => '30s',
            'http' => 'localhost',
            'token' => 'too-cool-for-this-http'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"http" *: *"localhost"}). \
            with_content(%r{"token" *: *"too-cool-for-this-http"}). \
            that_notifies('Class[consul::reload_service]') \
        }
      end

      describe 'with http and removed undef values' do
        let(:params) do
          {
            'interval' => '30s',
            'http' => 'localhost'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            without_content(%r{"service_id"}). \
            without_content(%r{"notes"})
        }
      end

      describe 'with ttl' do
        let(:params) do
          {
            'ttl' => '30s',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"ttl" *: *"30s"})
        }
      end

      describe 'with ttl and service_id' do
        let(:params) do
          {
            'ttl' => '30s',
            'service_id' => 'my_service'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"ttl" *: *"30s"}). \
            with_content(%r{"service_id" *: *"my_service"})
        }
      end

      describe 'reload service with ttl and token' do
        let(:params) do
          {
            'ttl' => '30s',
            'token' => 'too-cool-for-this-ttl'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"ttl" *: *"30s"}). \
            with_content(%r{"token" *: *"too-cool-for-this-ttl"}). \
            that_notifies('Class[consul::reload_service]') \
        }
      end

      describe 'with tcp' do
        let(:params) do
          {
            'tcp' => 'localhost:80',
            'interval' => '30s',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"tcp" *: *"localhost:80"}). \
            with_content(%r{"interval" *: *"30s"})
        }
      end

      describe 'with grpc' do
        let(:params) do
          {
            'grpc' => 'localhost:80',
            'interval' => '30s',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"grpc" *: *"localhost:80"})
        }
      end

      describe 'with grpc with interval' do
        let(:params) do
          {
            'grpc' => 'localhost:80',
            'interval' => '30s',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"grpc" *: *"localhost:80"}). \
            with_content(%r{"interval" *: *"30s"})
        }
      end

      describe 'with script and service_id' do
        let(:params) do
          {
            'tcp' => 'localhost:80',
            'interval' => '30s',
            'service_id' => 'my_service'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"check" *: *\{}). \
            with_content(%r{"tcp" *: *"localhost:80"}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"service_id" *: *"my_service"})
        }
      end

      describe 'reload service with script and token' do
        let(:params) do
          {
            'tcp' => 'localhost:80',
            'interval' => '30s',
            'token' => 'too-cool-for-this-script'
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_my_check.json'). \
            with_content(%r{"id" *: *"my_check"}). \
            with_content(%r{"name" *: *"my_check"}). \
            with_content(%r{"tcp" *: *"localhost:80"}). \
            with_content(%r{"interval" *: *"30s"}). \
            with_content(%r{"token" *: *"too-cool-for-this-script"}). \
            that_notifies('Class[consul::reload_service]') \
        }
      end

      describe 'with both ttl and interval' do
        let(:params) do
          {
            'ttl' => '30s',
            'interval' => '60s'
          }
        end

        it {
          is_expected.to raise_error(Puppet::Error, %r{script, http, tcp, grpc and interval must not be defined for ttl checks})
        }
      end

      describe 'with both ttl and script' do
        let(:params) do
          {
            'ttl' => '30s',
            'script' => 'true',
            'interval' => '60s'
          }
        end

        it {
          is_expected.to raise_error(Puppet::Error, %r{script, http, tcp, grpc and interval must not be defined for ttl checks})
        }
      end

      describe 'with both ttl and http' do
        let(:params) do
          {
            'ttl' => '30s',
            'http' => 'http://localhost/health',
            'interval' => '60s'
          }
        end

        it {
          is_expected.to raise_error(Puppet::Error, %r{script, http, tcp, grpc and interval must not be defined for ttl checks})
        }
      end

      describe 'with both ttl and tcp' do
        let(:params) do
          {
            'ttl' => '30s',
            'tcp' => 'localhost',
            'interval' => '60s'
          }
        end

        it {
          is_expected.to raise_error(Puppet::Error, %r{script, http, tcp, grpc and interval must not be defined for ttl checks})
        }
      end

      describe 'with both script and http' do
        let(:params) do
          {
            'script' => 'true',
            'http' => 'http://localhost/health',
            'interval' => '60s'
          }
        end

        it {
          is_expected.to raise_error(Puppet::Error, %r{script, tcp and grpc must not be defined for http checks})
        }
      end

      describe 'with script but no interval' do
        let(:params) do
          {
            'script' => 'true',
          }
        end

        it {
          is_expected.to raise_error(Puppet::Error, %r{interval must be defined for tcp, http, grpc and script checks})
        }
      end

      describe 'with http but no interval' do
        let(:params) do
          {
            'http' => 'http://localhost/health',
          }
        end

        it {
          is_expected.to raise_error(Puppet::Error, %r{interval must be defined for tcp, http, grpc and script checks})
        }
      end

      describe 'with tcp but no interval' do
        let(:params) do
          {
            'tcp' => 'localhost',
          }
        end

        it {
          is_expected.to raise_error(Puppet::Error, %r{interval must be defined for tcp, http, grpc and script checks})
        }
      end

      describe 'with a / in the id' do
        let(:params) do
          {
            'ttl' => '30s',
            'service_id' => 'my_service',
            'id' => 'aa/bb',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_aa_bb.json'). \
            with_content(%r{"id" *: *"aa/bb"})
        }
      end

      describe 'with multiple / in the id' do
        let(:params) do
          {
            'ttl' => '30s',
            'service_id' => 'my_service',
            'id' => 'aa/bb/cc',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/check_aa_bb_cc.json'). \
            with_content(%r{"id" *: *"aa/bb/cc"})
        }
      end
    end
  end
end
