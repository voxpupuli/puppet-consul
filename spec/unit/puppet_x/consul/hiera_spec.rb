require 'spec_helper'
require 'puppet_x/consul/hiera'

describe PuppetX::Consul::Hiera.method(:lookup_key) do
  let(:tmpdir) { Dir.mktmpdir }

  after(:each) {
    PuppetX::Consul::Cache.clear
    FileUtils.rm_r tmpdir
  }

  context 'confine_to_keys is set' do
    it 'should return for right key' do
      context = instance_double('Puppet::LookupContext')
      options = { 'confine_to_keys' => %w[zoo bar], 'uri' => 'http://localhost:8500/v1/kv/hiera/Common', 'document' => 'yaml', 'cache_dir' => tmpdir }
      key_value_data = [{
        'LockIndex' => 0,
        'Key' => 'hiera/Common',
        'Flags' => 0,
        'Value' => 'LS0tIA0KYmFyOiAidGVzdCB2YWx1ZSINCg==',
        'CreateIndex' => 893,
        'ModifyIndex' => 893
      }]

      expect(context).to receive(:cache_has_key).at_least(:once)
      expect(context).to receive(:cache).at_least(:once)

      stub_request(:get, 'http://localhost:8500/v1/kv/hiera/Common')
        .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

      expect(subject.call('bar', options, context)).to eql('test value')
    end

    it 'should fail for wrong key' do
      context = instance_double('Puppet::LookupContext')
      expect(context).to receive(:explain)
      expect(context).to receive(:not_found)

      options = { 'confine_to_keys' => %w[zoo bar], 'uri' => 'http://localhost:8500/v1/kv/common', 'cache_dir' => tmpdir }

      expect(subject.call('baz', options, context))
    end

    it 'raises ArgumentError if confine_to_keys is not an array' do
      options = { 'confine_to_keys' => 'bar', 'uri' => 'http://localhost:8500/v1/kv/common' }

      expect { subject.call('bar', options, nil) }.to raise_error(ArgumentError, 'confine_to_keys must be an array')
    end

    it 'raises ArgumentError if not querying kv' do
      options = { 'confine_to_keys' => 'bar', 'uri' => 'http://localhost:8500/csss/common', 'cache_dir' => tmpdir }

      expect { subject.call('bar', options, nil) }.to raise_error(ArgumentError, 'confine_to_keys must be an array')
    end
  end

  context 'lookup types' do
    context 'literal' do
      it 'returns value when not using __KEY__' do
        context = instance_double('Puppet::LookupContext')
        options = { 'confine_to_keys' => %w[zoo bar], 'uri' => 'http://localhost:8500/v1/kv/hiera/Common', 'document' => 'yaml', 'cache_dir' => tmpdir }
        key_value_data = [{
          'LockIndex' => 0,
          'Key' => 'hiera/Common',
          'Flags' => 0,
          'Value' => 'LS0tIA0KYmFyOiAidGVzdCB2YWx1ZSINCg==',
          'CreateIndex' => 893,
          'ModifyIndex' => 893
        }]

        expect(context).to receive(:cache_has_key).at_least(:once)
        expect(context).to receive(:cache).at_least(:once)

        stub_request(:get, 'http://localhost:8500/v1/kv/hiera/Common')
          .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

        expect(subject.call('bar', options, context)).to eql('test value')
      end

      context 'document is yaml' do
        it 'returns value when using __KEY__' do
          context = instance_double('Puppet::LookupContext')
          options = { 'confine_to_keys' => ['abc'], 'uri' => 'http://localhost:8500/v1/kv/hiera/keys/__KEY__', 'document' => 'yaml', 'cache_dir' => tmpdir }

          key_value_data = [{
            'LockIndex' => 0,
            'Key' => 'hiera/keys/abc',
            'Flags' => 0,
            'Value' => 'YWJjOiBrZXktdmFsdWUgaW5jbHVkaW5nIGtleQ==',
            'CreateIndex' => 894,
            'ModifyIndex' => 894
          }]

          expect(context).to receive(:cache_has_key).at_least(:once)
          expect(context).to receive(:cache).at_least(:once)

          stub_request(:get, 'http://localhost:8500/v1/kv/hiera/keys/abc')
            .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

          expect(subject.call('abc', options, context)).to eql('abc' => 'key-value including key')
        end

        it 'fail with an illegal yaml document' do
          context = instance_double('Puppet::LookupContext')
          options = { 'confine_to_keys' => ['abc'], 'uri' => 'http://localhost:8500/v1/kv/hiera/keys/__KEY__', 'document' => 'yaml', 'cache_dir' => tmpdir }

          key_value_data = [{
            'LockIndex' => 0,
            'Key' => 'hiera/keys/abc',
            'Flags' => 0,
            'Value' => 'LS0tIA0KYWJjOiBhY3g6',
            'CreateIndex' => 894,
            'ModifyIndex' => 894
          }]

          stub_request(:get, 'http://localhost:8500/v1/kv/hiera/keys/abc')
            .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

          expect(context).to receive(:cache_has_key).at_least(:once)

          expect { subject.call('abc', options, context) }.to raise_error(Puppet::DataBinding::LookupError, 'hiera_consul failed could not parse yaml document for key: abc on uri: http://localhost:8500/v1/kv/hiera/keys/__KEY__')
        end
      end

      context 'document is json' do
        it 'returns value when using __KEY__' do
          context = instance_double('Puppet::LookupContext')
          options = { 'confine_to_keys' => ['abc'], 'uri' => 'http://localhost:8500/v1/kv/hiera/keys/__KEY__', 'document' => 'json', 'cache_dir' => tmpdir }

          key_value_data = [{
            'LockIndex' => 0,
            'Key' => 'hiera/keys/abc',
            'Flags' => 0,
            'Value' => 'ew0KCSJhYmMiOiAia2V5LXZhbHVlIGluY2x1ZGluZyBrZXkiDQp9',
            'CreateIndex' => 894,
            'ModifyIndex' => 894
          }]

          expect(context).to receive(:cache_has_key).at_least(:once)
          expect(context).to receive(:cache).at_least(:once)

          stub_request(:get, 'http://localhost:8500/v1/kv/hiera/keys/abc')
            .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

          expect(subject.call('abc', options, context)).to eql('abc' => 'key-value including key')
        end

        it 'fail with an illegal json document' do
          context = instance_double('Puppet::LookupContext')
          options = { 'confine_to_keys' => ['abc'], 'uri' => 'http://localhost:8500/v1/kv/hiera/keys/__KEY__', 'document' => 'json', 'cache_dir' => tmpdir }

          key_value_data = [{
            'LockIndex' => 0,
            'Key' => 'hiera/keys/abc',
            'Flags' => 0,
            'Value' => 'LS0tIA0KYWJjOiBhY3g6',
            'CreateIndex' => 894,
            'ModifyIndex' => 894
          }]

          stub_request(:get, 'http://localhost:8500/v1/kv/hiera/keys/abc')
            .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

          expect(context).to receive(:cache_has_key).at_least(:once)

          expect { subject.call('abc', options, context) }.to raise_error(Puppet::DataBinding::LookupError, 'hiera_consul failed could not parse json document for key: abc on uri: http://localhost:8500/v1/kv/hiera/keys/__KEY__')
        end
      end
    end

    context 'recursive' do
      it 'returns hash when using yaml' do
        context = instance_double('Puppet::LookupContext')
        options = { 'confine_to_keys' => ['recursive'], 'uri' => 'http://localhost:8500/v1/kv/hiera/recursive/__KEY__?recurse', 'document' => 'yaml', 'cache_dir' => tmpdir }
        key_value_data = [{
          'LockIndex' => 0,
          'Key' => 'hiera/recursive/recursive/node1',
          'Flags' => 0,
          'Value' => 'LS0tIA0KbGlzdDogDQogIC0gYWJjDQogIC0gZGVmDQpvcGV4OiB0ZWFtMTINCg==',
          'CreateIndex' => 896,
          'ModifyIndex' => 896
          },
          {
            'LockIndex' => 0,
            'Key' => 'hiera/recursive/recursive/node2',
            'Flags' => 0,
            'Value' => 'b3BleDogdGVhbTEy',
            'CreateIndex' => 895,
            'ModifyIndex' => 895
          },
          {
            'LockIndex' => 0,
            'Key' => 'hiera/recursive/recursive/lvl/node3',
            'Flags' => 0,
            'Value' => 'b3BleDogdGVhbTEy',
            'CreateIndex' => 895,
            'ModifyIndex' => 895
        }]

        result = {
          'lvl' => { 'node3' => { 'opex' => 'team12' } },
          'node2' => { 'opex' => 'team12' },
          'node1' => { 'opex' => 'team12', 'list' => %w[abc def] }
        }

        expect(context).to receive(:cache_has_key).at_least(:once)
        expect(context).to receive(:cache).at_least(:once)

        stub_request(:get, 'http://localhost:8500/v1/kv/hiera/recursive/recursive?recurse')
          .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

        expect(subject.call('recursive', options, context)).to eql(result)
      end

      it 'returns hash when using json' do
        context = instance_double('Puppet::LookupContext')
        options = { 'confine_to_keys' => ['recursive'], 'uri' => 'http://localhost:8500/v1/kv/hiera/recursive/__KEY__?recurse', 'document' => 'json', 'cache_dir' => tmpdir }
        key_value_data = [{
          'LockIndex' => 0,
          'Key' => 'hiera/recursive/recursive/node1',
          'Flags' => 0,
          'Value' => 'ew0KCSJvcGV4IjogInRlYW0xMiIsDQoJImxpc3QiOiBbImFiYyIsICJkZWYiXQ0KfQ==',
          'CreateIndex' => 896,
          'ModifyIndex' => 896
        },
        {
          'LockIndex' => 0,
          'Key' => 'hiera/recursive/recursive/node2',
          'Flags' => 0,
          'Value' => 'ew0KCSJvcGV4IjogInRlYW0xMiINCn0=',
          'CreateIndex' => 895,
          'ModifyIndex' => 895
        },
        {
          'LockIndex' => 0,
          'Key' => 'hiera/recursive/recursive/lvl/node3',
          'Flags' => 0,
          'Value' => 'ew0KCSJvcGV4IjogInRlYW1hd2Vvc21lIg0KfQ==',
          'CreateIndex' => 895,
          'ModifyIndex' => 895
        }]

        result = {
          'lvl' => { 'node3' => { 'opex' => 'teamaweosme' } },
          'node2' => { 'opex' => 'team12' },
          'node1' => { 'opex' => 'team12', 'list' => %w[abc def] }
        }

        expect(context).to receive(:cache_has_key).at_least(:once)
        expect(context).to receive(:cache).at_least(:once)

        stub_request(:get, 'http://localhost:8500/v1/kv/hiera/recursive/recursive?recurse')
          .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

        expect(subject.call('recursive', options, context)).to eql(result)
      end

      it 'raise error when document is corrupt' do
        context = instance_double('Puppet::LookupContext')
        options = { 'confine_to_keys' => ['recursive'], 'uri' => 'http://localhost:8500/v1/kv/hiera/recursive/__KEY__?recurse', 'document' => 'json', 'cache_dir' => tmpdir }
        key_value_data = [{
          'LockIndex' => 0,
          'Key' => 'hiera/recursive/recursive/node1',
          'Flags' => 0,
          'Value' => 'LS0tIA0KbGlzdDogDQogIC0gYWJjDQogIC0gZGVmDQpvcGV4OiB0ZWFtMTINCg==',
          'CreateIndex' => 896,
          'ModifyIndex' => 896
        }]

        expect(context).to receive(:cache_has_key).at_least(:once)

        stub_request(:get, 'http://localhost:8500/v1/kv/hiera/recursive/recursive?recurse')
          .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})

        expect { subject.call('recursive', options, context) }.to raise_error(Puppet::DataBinding::LookupError)
      end
    end
  end

  context 'caching' do
    it 'should use cache if consul becomes unreachable' do
      context = instance_double('Puppet::LookupContext')
      options = { 'confine_to_keys' => %w[zoo bar], 'uri' => 'http://localhost:8500/v1/kv/hiera/Common', 'document' => 'yaml', 'cache_dir' => tmpdir }
      key_value_data = [{
        'LockIndex' => 0,
        'Key' => 'hiera/Common',
        'Flags' => 0,
        'Value' => 'LS0tIA0KYmFyOiAidGVzdCB2YWx1ZSINCg==',
        'CreateIndex' => 893,
        'ModifyIndex' => 893
      }]

      expect(context).to receive(:cache_has_key).at_least(:once)
      expect(context).to receive(:cache).at_least(:once)

      stub_request(:get, 'http://localhost:8500/v1/kv/hiera/Common')
        .to_return(:status => 200, :body => JSON.dump(key_value_data), :headers => {})
        .to_timeout

      expect(subject.call('bar', options, context)).to eql('test value')

      expect(subject.call('bar', options, context)).to eql('test value')
    end

    it 'should raise error if unavailable' do
      context = instance_double('Puppet::LookupContext')
      options = { 'confine_to_keys' => %w[zoo bar], 'uri' => 'http://localhost:8500/v1/kv/hiera/Common', 'document' => 'yaml', 'cache_dir' => tmpdir }
      key_value_data = [{
        'LockIndex' => 0,
        'Key' => 'hiera/Common',
        'Flags' => 0,
        'Value' => 'LS0tIA0KYmFyOiAidGVzdCB2YWx1ZSINCg==',
        'CreateIndex' => 893,
        'ModifyIndex' => 893
      }]

      expect(context).to receive(:cache_has_key).at_least(:once)

      stub_request(:get, 'http://localhost:8500/v1/kv/hiera/Common')
        .to_timeout

      expect{ subject.call('bar', options, context) }.to raise_error(Puppet::Error)
    end

    it 'should raise error if a timeout occurs without cache' do
      context = instance_double('Puppet::LookupContext')
      options = { 'confine_to_keys' => %w[zoo bar], 'uri' => 'http://localhost:8500/v1/kv/hiera/Common', 'document' => 'yaml', 'cache_dir' => tmpdir }
      key_value_data = [{
        'LockIndex' => 0,
        'Key' => 'hiera/Common',
        'Flags' => 0,
        'Value' => 'LS0tIA0KYmFyOiAidGVzdCB2YWx1ZSINCg==',
        'CreateIndex' => 893,
        'ModifyIndex' => 893
      }]

      expect(context).to receive(:cache_has_key).at_least(:once)

      stub_request(:get, 'http://localhost:8500/v1/kv/hiera/Common')
        .to_timeout

      expect{ subject.call('bar', options, context) }.to raise_error(Puppet::Error)
    end

    it 'should raise error on connection trouble without cache' do
      context = instance_double('Puppet::LookupContext')
      options = { 'confine_to_keys' => %w[zoo bar], 'uri' => 'http://localhost:8500/v1/kv/hiera/Common', 'document' => 'yaml' }
      key_value_data = [{
        'LockIndex' => 0,
        'Key' => 'hiera/Common',
        'Flags' => 0,
        'Value' => 'LS0tIA0KYmFyOiAidGVzdCB2YWx1ZSINCg==',
        'CreateIndex' => 893,
        'ModifyIndex' => 893
      }]

      expect(context).to receive(:cache_has_key).at_least(:once)

      stub_request(:get, 'http://localhost:8500/v1/kv/hiera/Common')
        .to_raise(Errno::ECONNRESET)

      expect{ subject.call('bar', options, context) }.to raise_error(Puppet::Error)
    end
  end
end

