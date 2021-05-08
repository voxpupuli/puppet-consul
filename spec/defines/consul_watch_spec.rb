require 'spec_helper'

describe 'consul::watch' do
  on_supported_os.each do |os, facts|
    next unless facts[:kernel] == 'Linux'
    context "on #{os} " do
      let :facts do
        facts
      end
      let(:title) { 'my_watch' }

      describe 'version checks' do
        context 'with recent versions' do
          let(:params) do
            {
              'type' => 'nodes',
           'handler' => 'handler_path',
            }
          end

          it {
            is_expected.to contain_file('/etc/consul/watch_my_watch.json')
          }
        end
      end

      describe 'with no args' do
        let(:params) { {} }

        it {
          expect { is_expected.to raise_error(Puppet::Error) }
        }
      end

      describe 'with handler no type' do
        let(:params) do
          {
            'handler' => 'handler_path',
          }
        end

        it {
          expect { is_expected.to raise_error(Puppet::Error) }
        }
      end

      describe 'with valid type no handler' do
        let(:params) do
          {
            'type' => 'nodes',
          }
        end

        it {
          expect { is_expected.to raise_error(Puppet::Error) }
        }
      end

      describe 'with valid type and handler' do
        let(:params) do
          {
            'type' => 'nodes',
         'handler' => 'handler_path',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(%r{"handler" *: *"handler_path"}) \
            .with_content(%r{"type" *: *"nodes"})
        }
      end

      describe 'with valid type and args' do
        let(:params) do
          {
            'type' => 'nodes',
         'args' => ['sh', '-c', 'true'],
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(%r{"args" *: *\[ *"sh", *"-c", *"true" *\]}) \
            .with_content(%r{"type" *: *"nodes"})
        }
      end

      describe 'with both args and handler' do
        let(:params) do
          {
            'type' => 'nodes',
         'handler' => 'handler_path',
         'args' => ['sh', '-c', 'true'],
          }
        end

        it {
          expect { is_expected.to raise_error(Puppet::Error) }
        }
      end

      describe 'global attributes' do
        let(:params) do
          {
            'type' => 'nodes',
         'handler' => 'handler_path',

         'datacenter' => 'dcName',
         'token' => 'tokenValue',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(%r{"datacenter" *: *"dcName"}) \
            .with_content(%r{"token" *: *"tokenValue"})
        }
      end

      describe 'type validation' do
        context '"key" type' do
          context 'without key' do
            let(:params) do
              {
                'type' => 'key',
             'handler' => 'handler_path'
              }
            end

            it {
              expect { is_expected.to raise_error(Puppet::Error) }
            }
          end
          context 'with key' do
            let(:params) do
              {
                'type' => 'key',
             'handler' => 'handler_path',

             'key'     => 'KeyName',
              }
            end

            it {
              is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
                .with_content(%r{"type" *: *"key"}) \
                .with_content(%r{"key" *: *"KeyName"})
            }
          end
        end

        context '"keyprefix" type' do
          context 'without keyprefix' do
            let(:params) do
              {
                'type' => 'keyprefix',
             'handler' => 'handler_path'
              }
            end

            it {
              expect { is_expected.to raise_error(Puppet::Error) }
            }
          end

          context 'with keyprefix' do
            let(:params) do
              {
                'type' => 'keyprefix',
             'handler'   => 'handler_path',

             'keyprefix' => 'keyPref',
              }
            end

            it {
              is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
                .with_content(%r{"type" *: *"keyprefix"}) \
                .with_content(%r{"prefix" *: *"keyPref"})
            }
          end
        end

        context '"service" type' do
          context 'without service' do
            let(:params) do
              {
                'type'      => 'service',
             'handler'   => 'handler_path',
              }
            end

            it {
              expect { is_expected.to raise_error(Puppet::Error) }
            }
          end

          context 'with service' do
            let(:params) do
              {
                'type'      => 'service',
             'handler'   => 'handler_path',

             'service'   => 'serviceName',
              }
            end

            it {
              is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
                .with_content(%r{"type" *: *"service"}) \
                .with_content(%r{"service" *: *"serviceName"})
            }
          end

          context 'with all optionals' do
            let(:params) do
              {
                'type' => 'service',
             'handler'     => 'handler_path',
             'service'     => 'serviceName',

             'service_tag' => 'serviceTagName',
             'passingonly' => true
              }
            end

            it {
              is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
                .with_content(%r{"tag" *: *"serviceTagName"}) \
                .with_content(%r{"passingonly" *: *true})
            }
          end
        end

        context '"checks" type' do
          context 'without optionals' do
            let(:params) do
              {
                'type' => 'checks',
             'handler' => 'handler_path',
              }
            end

            it {
              is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
                .with_content(%r{"type" *: *"checks"})
            }
          end

          context 'with all optionals' do
            let(:params) do
              {
                'type' => 'checks',
             'handler' => 'handler_path',

             'service' => 'serviceName',
             'state'   => 'serviceState',
              }
            end

            it {
              is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
                .with_content(%r{"service" *: *"serviceName"}) \
                .with_content(%r{"state" *: *"serviceState"})
            }
          end
        end

        context '"event" type' do
          context 'without optionals' do
            let(:params) do
              {
                'type' => 'event',
             'handler'   => 'handler_path',
              }
            end

            it {
              is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
                .with_content(%r{"type" *: *"event"})
            }
          end

          context 'with optionals' do
            let(:params) do
              {
                'type' => 'event',
             'handler'   => 'handler_path',

             'event_name' => 'eventName',
              }
            end

            it {
              is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
                .with_content(%r{"name" *: *"eventName"})
            }
          end
        end

        context '"nodes" type' do
          let(:params) do
            {
              'type' => 'nodes',
           'handler' => 'handler_path'
            }
          end

          it {
            is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
              .with_content(%r{"type" *: *"nodes"})
          }
        end

        context '"services" type' do
          let(:params) do
            {
              'type' => 'services',
           'handler' => 'handler_path'
            }
          end

          it {
            is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
              .with_content(%r{"type" *: *"services"})
          }
        end

        context '"unknown_type" type' do
          let(:params) do
            {
              'type' => 'unknown_type',
           'handler' => 'handler_path',
            }
          end

          it {
            expect { is_expected.to raise_error(Puppet::Error) }
          }
        end
      end

      describe 'notify reload service' do
        let(:params) do
          {
            'type' => 'nodes',
         'handler' => 'handler_path',
          }
        end

        it {
          is_expected.to contain_file('/etc/consul/watch_my_watch.json') \
            .that_notifies('Class[consul::reload_service]') \
        }
      end
    end
  end
end
