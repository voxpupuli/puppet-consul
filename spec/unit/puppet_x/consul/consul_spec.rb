require 'spec_helper'
require 'puppet_x/consul/consul'

describe PuppetX::Consul::Consul do
  context 'execute a raw get' do
    it 'should return the right value' do
      consulclient = described_class.new

      stub_request(:get, 'http://localhost:8500/')
        .with(headers: { 'X-Consul-Token' => '' })
        .to_return(status: 200, body: 'hello api', headers: {})

      response = consulclient.get('/')
      expect(response.body).to eql('hello api')
    end

    it 'should set the right token' do
      consulclient = described_class.new('localhost', 'SAMPLETOKEN', 8500)

      stub_request(:get, 'http://localhost:8500/')
        .with(headers: { 'X-Consul-Token' => 'SAMPLETOKEN' })
        .to_return(status: 200, body: 'hello api', headers: {})

      response = consulclient.get('/')
      expect(response.body).to eql('hello api')
    end

    it 'should support basic auth' do
      consulclient = described_class.new('localhost', 'SAMPLETOKEN', 8500,
                                         use_auth: true, auth_user: 'consul', auth_pass: 'PASSWORD')

      stub_request(:get, 'http://localhost:8500/')
        .with(headers: { 'X-Consul-Token' => 'SAMPLETOKEN' })
        .with(basic_auth: %w[consul PASSWORD])
        .to_return(status: 200, body: 'hello api', headers: {})

      response = consulclient.get('/')
      expect(response.body).to eql('hello api')
    end

    it 'should support ssl' do
      consulclient = described_class.new('localhost', 'SAMPLETOKEN', 8500,
                                         use_ssl: true)

      stub_request(:get, 'https://localhost:8500/')
        .with(headers: { 'X-Consul-Token' => 'SAMPLETOKEN' })
        .to_return(status: 200, body: 'hello api', headers: {})

      response = consulclient.get('/')
      expect(response.body).to eql('hello api')
    end
  end

  context 'in the key value store' do
    context 'retrieve data' do
      it 'for a single key' do
        kv_content = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'RGlmZmVyZW50IHZhbHVl', # Different value
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        kv_content_expected = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'Different value', # Different value
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample/key')
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new
        response = consulclient.get_kv('sample/key')
        expect(response).to eql([kv_content_expected, 1_350_503])
      end

      it 'recursively' do
        kv_content = [
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/', 'Flags' => 0, 'Value' => nil, 'CreateIndex' => 6_165_067, 'ModifyIndex' => 6_165_067 },
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/01-latest-rhel5s/repotag', 'Flags' => 0, 'Value' => 'MjAxNjA2MzA=', 'CreateIndex' => 22_637_812, 'ModifyIndex' => 22_637_812 },
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/01-latest-rhel6s/repotag', 'Flags' => 0, 'Value' => 'MjAxNzEwMDI=', 'CreateIndex' => 22_629_109, 'ModifyIndex' => 48_846_061 }
        ]

        kv_content_expected = [
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/', 'Flags' => 0, 'Value' => nil, 'CreateIndex' => 6_165_067, 'ModifyIndex' => 6_165_067 },
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/01-latest-rhel5s/repotag', 'Flags' => 0, 'Value' => '20160630', 'CreateIndex' => 22_637_812, 'ModifyIndex' => 22_637_812 },
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/01-latest-rhel6s/repotag', 'Flags' => 0, 'Value' => '20171002', 'CreateIndex' => 22_629_109, 'ModifyIndex' => 48_846_061 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample?recurse')
          .with(headers: { 'X-Consul-Token' => '' })
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new
        response = consulclient.get_kv('sample', 'recurse' => true)
        expect(response).to eql([kv_content_expected, 48_846_061])
      end

      it 'cannot find anything' do
        stub_request(:get, 'http://localhost:8500/v1/kv/sample/key')
          .to_return(status: 404, headers: {})

        consulclient = described_class.new
        response = consulclient.get_kv('sample/key')
        expect(response).to eql([])
      end

      it 'with a different datacenter' do
        kv_content = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'RGlmZmVyZW50IHZhbHVl', # Different value
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        kv_content_expected = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'Different value', # Different value
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample/key?dc=dc2')
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new
        response = consulclient.get_kv('sample/key', 'dc' => 'dc2')
        expect(response).to eql([kv_content_expected, 1_350_503])
      end

      it 'with recurse and dc' do
        kv_content = [
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/', 'Flags' => 0, 'Value' => nil, 'CreateIndex' => 6_165_067, 'ModifyIndex' => 6_165_067 },
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/01-latest-rhel5s/repotag', 'Flags' => 0, 'Value' => 'MjAxNjA2MzA=', 'CreateIndex' => 22_637_812, 'ModifyIndex' => 22_637_812 },
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/01-latest-rhel6s/repotag', 'Flags' => 0, 'Value' => 'MjAxNzEwMDI=', 'CreateIndex' => 22_629_109, 'ModifyIndex' => 48_846_061 }
        ]

        kv_content_expected = [
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/', 'Flags' => 0, 'Value' => nil, 'CreateIndex' => 6_165_067, 'ModifyIndex' => 6_165_067 },
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/01-latest-rhel5s/repotag', 'Flags' => 0, 'Value' => '20160630', 'CreateIndex' => 22_637_812, 'ModifyIndex' => 22_637_812 },
          { 'LockIndex' => 0, 'Key' => 'sample/kickstart/01-latest-rhel6s/repotag', 'Flags' => 0, 'Value' => '20171002', 'CreateIndex' => 22_629_109, 'ModifyIndex' => 48_846_061 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample?recurse&dc=dc2&recurse')
          .with(headers: { 'X-Consul-Token' => '' })
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new
        response = consulclient.get_kv('sample', 'recurse' => true, 'dc' => 'dc2')
        expect(response).to eql([kv_content_expected, 48846061])
      end

      it 'should parse yaml in value' do
        kv_content = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'LS0tDQpmcnVpdHM6DQogICAgLSBBcHBsZQ0KICAgIC0gT3JhbmdlDQogICAgLSBTdHJhd2JlcnJ5DQogICAgLSBNYW5nbw==',
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        kv_content_expected = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => { 'fruits' => %w[Apple Orange Strawberry Mango] },
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample/key')
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new('localhost', '', 8500, document: 'YAML')
        response = consulclient.get_kv('sample/key')
        expect(response).to eql([kv_content_expected, 1_350_503])
      end

      it 'should parse json in value' do
        kv_content = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'eyJoZWxsbyI6ICJnb29kYnllIn0=',
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        kv_content_expected = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => { 'hello' => 'goodbye' },
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample/key')
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new('localhost', '', 8500, document: 'JSON')
        response = consulclient.get_kv('sample/key')
        expect(response).to eql([kv_content_expected, 1_350_503])
      end

      it 'should return raw data in value' do
        kv_content = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'eyJoZWxsbyI6ICJnb29kYnllIn0=',
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        kv_content_expected = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => '{"hello": "goodbye"}',
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample/key')
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new('localhost', '', 8500, document: 'raw')
        response = consulclient.get_kv('sample/key')
        expect(response).to eql([kv_content_expected, 1_350_503] )
      end

      it 'should Error on invalid yaml data' do
        kv_content = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'amVsOiBzc3MgLSA6IHNkYXNkIg==',
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample/key')
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new('localhost', '', 8500, document: 'yaml')
        expect { consulclient.get_kv('sample/key') }.to raise_error(PuppetX::Consul::ConsulValueError)
      end

      it 'should error on invalid json data' do
        kv_content = [
          { 'LockIndex' => 0,
            'Key' => 'sample/key',
            'Flags' => 0,
            'Value' => 'LS0tDQpmcnVpdHM6DQogICAgLSBBcHBsZQ0KICAgIC0gT3JhbmdlDQogICAgLSBTdHJhd2JlcnJ5DQogICAgLSBNYW5nbw=',
            'CreateIndex' => 1_350_503,
            'ModifyIndex' => 1_350_503 }
        ]

        stub_request(:get, 'http://localhost:8500/v1/kv/sample/key')
          .to_return(status: 200, body: JSON.dump(kv_content), headers: {})

        consulclient = described_class.new('localhost', '', 8500, document: 'JSON')
        expect { consulclient.get_kv('sample/key') }.to raise_error(PuppetX::Consul::ConsulValueError)
      end
    end
  end
end
