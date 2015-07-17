require 'spec_helper'

describe 'consul::watch' do
  let(:facts) {{ :architecture => 'x86_64', :version => '0.4.0' }}
  let(:title) { "my_watch" }

  describe 'version checks' do
    context 'with version < 0.4.0' do
      let (:facts) {{ :architecture => 'x86_64' }}
      let(:hiera_data) {{ 'consul::version' => '0.3.0' }}
      let (:params) {{
        'type'    => 'nodes',
        'handler' => 'handler_path',
      }}
      it {
        expect {
          should contain_file('/etc/consul/watch_my_watch.json')
        }.to raise_error(Puppet::Error, /Watches are only supported in Consul 0.4.0 and above/)
      }
    end

    context 'with version 0.4.1' do
      let (:facts) {{ :architecture => 'x86_64' }}
      let(:hiera_data) {{ 'consul::version' => '0.4.1' }}
      let (:params) {{
        'type'    => 'nodes',
        'handler' => 'handler_path',
      }}
      it {
        should contain_file('/etc/consul/watch_my_watch.json')
      }
    end

    context 'with version 1.3.0' do
      let (:facts) {{ :architecture => 'x86_64' }}
      let(:hiera_data) {{ 'consul::version' => '1.3.0' }}
      let (:params) {{
        'type'    => 'nodes',
        'handler' => 'handler_path',
      }}
      it {
        should contain_file('/etc/consul/watch_my_watch.json')
      }
    end
  end

  describe 'with no args' do
    let(:params) {{}}

    it {
      expect { should raise_error(Puppet::Error)}
    }
  end

  describe 'with handler no type' do
    let(:params) {{
      'handler' => 'handler_path',
    }}
    it {
      expect { should raise_error(Puppet::Error)}
    }
  end

  describe 'with valid type no handler' do
    let(:params) {{
      'type'  => 'nodes',
    }}
    it {
      expect { should raise_error(Puppet::Error)}
    }
  end

  describe 'with valid type and handler' do
    let(:params) {{
      'type'    => 'nodes',
      'handler' => 'handler_path',
    }}
    it {
      should contain_file('/etc/consul/watch_my_watch.json') \
          .with_content(/"handler" *: *"handler_path"/) \
          .with_content(/"type" *: *"nodes"/)
    }
  end

  describe 'global attributes' do
    let (:params) {{
      'type' => 'nodes',
      'handler' => 'handler_path',

      'datacenter' => 'dcName',
      'token' => 'tokenValue',
    }}
    it {
      should contain_file('/etc/consul/watch_my_watch.json') \
          .with_content(/"datacenter" *: *"dcName"/) \
          .with_content(/"token" *: *"tokenValue"/)
    }
  end

  describe 'type validation' do
    context '"key" type' do
      context 'without key' do
        let (:params) {{
          'type'  => 'key',
          'handler' => 'handler_path'
        }}
        it {
          expect { should raise_error(Puppet::Error)}
        }
      end
      context 'with key' do
        let (:params) {{
          'type'    => 'key',
          'handler' => 'handler_path',

          'key'     => 'KeyName',
        }}
        it {
          should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"type" *: *"key"/) \
            .with_content(/"key" *: *"KeyName"/)
        }
      end
    end

    context '"keyprefix" type' do
      context 'without keyprefix' do
        let (:params) {{
          'type'    => 'keyprefix',
          'handler' => 'handler_path'
        }}
        it {
          expect { should raise_error(Puppet::Error)}
        }
      end

      context 'with keyprefix' do
        let (:params) {{
          'type'      => 'keyprefix',
          'handler'   => 'handler_path',

          'keyprefix' => 'keyPref',
        }}
        it {
          should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"type" *: *"keyprefix"/) \
            .with_content(/"prefix" *: *"keyPref"/)
        }
      end
    end

    context '"service" type' do
      context 'without service' do
        let (:params) {{
          'type'      => 'service',
          'handler'   => 'handler_path',
        }}
        it {
          expect { should raise_error(Puppet::Error) }
        }
      end

      context 'with service' do
        let (:params) {{
          'type'      => 'service',
          'handler'   => 'handler_path',

          'service'   => 'serviceName',
        }}
        it {
          should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"type" *: *"service"/) \
            .with_content(/"service" *: *"serviceName"/)
        }
      end

      context 'with all optionals' do
        let (:params) {{
          'type'        => 'service',
          'handler'     => 'handler_path',
          'service'     => 'serviceName',

          'service_tag' => 'serviceTagName',
          'passingonly' => true
        }}
        it {
          should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"tag" *: *"serviceTagName"/) \
            .with_content(/"passingonly" *: *true/)
        }
      end
    end

    context '"checks" type' do
      context 'without optionals' do
        let (:params) {{
          'type'      => 'checks',
          'handler'   => 'handler_path',
        }}
        it {
          should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"type" *: *"checks"/)
        }
      end

      context 'with all optionals' do
        let (:params) {{
          'type'    => 'checks',
          'handler' => 'handler_path',

          'service' => 'serviceName',
          'state'   => 'serviceState',
        }}
        it {
          should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"service" *: *"serviceName"/) \
            .with_content(/"state" *: *"serviceState"/)
        }
      end
    end

    context '"event" type' do
      context 'without optionals' do
        let (:params) {{
          'type'      => 'event',
          'handler'   => 'handler_path',
        }}
        it {
          should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"type" *: *"event"/)
        }
      end

      context 'with optionals' do
        let (:params) {{
          'type'      => 'event',
          'handler'   => 'handler_path',

          'event_name'=> 'eventName',
        }}
        it {
          should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"name" *: *"eventName"/)
        }
      end
    end

    context '"nodes" type' do
      let (:params) {{
        'type'    => 'nodes',
        'handler' => 'handler_path'
      }}
      it {
        should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"type" *: *"nodes"/)
      }
    end

    context '"services" type' do
      let (:params) {{
        'type'    => 'services',
        'handler' => 'handler_path'
      }}
      it {
        should contain_file('/etc/consul/watch_my_watch.json') \
            .with_content(/"type" *: *"services"/)
      }
    end

    context '"unknown_type" type' do
      let(:params) {{
        'type'    => 'unknown_type',
        'handler' => 'handler_path',
      }}
      it {
        expect { should raise_error(Puppet::Error)}
      }
    end

  end

  describe 'notify reload service' do
    let (:params) {{
      'type' => 'nodes',
      'handler' => 'handler_path',
    }}
    it {
      should contain_file('/etc/consul/watch_my_watch.json') \
          .that_notifies("Class[consul::reload_service]") \
    }
  end
end
