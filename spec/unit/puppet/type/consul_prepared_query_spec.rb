require 'spec_helper'

describe Puppet::Type.type(:consul_prepared_query) do
  it 'fails if no name is provided' do
    expect do
      Puppet::Type.type(:consul_prepared_query).new(type: 'client')
    end.to raise_error(Puppet::Error, %r{Title or name must be provided})
  end

  it 'fails if node_meta is not a hash' do
    expect do
      Puppet::Type.type(:consul_prepared_query).new(
        name: 'testing',
        node_meta: 'test'
      )
    end.to raise_error(Puppet::Error, %r{NodeMeta type must be a hash})
  end

  it 'fails if service_meta is not a hash' do
    expect do
      Puppet::Type.type(:consul_prepared_query).new(
        name: 'testing',
        service_meta: 'test'
      )
    end.to raise_error(Puppet::Error, %r{ServiceMeta type must be a hash})
  end

  context 'with query parameters provided' do
    before do
      @prepared_query = Puppet::Type.type(:consul_prepared_query).new(
        name: 'testing',
        token: '',
        service_name: 'testing',
        service_failover_n: 1,
        service_failover_dcs: %w[dc1 dc2],
        service_tags: %w[tag1 tag2],
        service_only_passing: true,
        ttl: 10,
        node_meta: { 'is_virtual' => 'false' },
        service_meta: { 'version' => '1.2.3' }
      )
    end

    it 'defaults to localhost' do
      expect(@prepared_query[:hostname]).to eq('localhost')
    end

    it 'defaults to http' do
      expect(@prepared_query[:protocol]).to eq(:http)
    end

    it 'returns node_meta hash' do
      expect(@prepared_query[:node_meta]).to eq({ 'is_virtual' => 'false' })
    end

    it 'returns service_meta hash' do
      expect(@prepared_query[:service_meta]).to eq({ 'version' => '1.2.3' })
    end
  end
end
