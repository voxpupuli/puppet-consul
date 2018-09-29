require 'spec_helper'

describe Puppet::Type.type(:consul_prepared_query) do

  it 'should fail if no name is provided' do
    expect do
      Puppet::Type.type(:consul_prepared_query).new(:type => 'client')
    end.to raise_error(Puppet::Error, /Title or name must be provided/)
  end

  context 'with query parameters provided' do
    before :each do
      @prepared_query = Puppet::Type.type(:consul_prepared_query).new(
        :name                 => 'testing',
        :token                => '',
        :service_name         => 'testing',
        :service_failover_n   => 1,
        :service_failover_dcs => [ 'dc1', 'dc2' ],
        :service_tags         => [ 'tag1', 'tag2' ],
        :service_only_passing => true,
        :ttl                  => 10
      )
    end

    it 'should default to localhost' do
      expect(@prepared_query[:hostname]).to eq('localhost')
    end

    it 'should default to http' do
      expect(@prepared_query[:protocol]).to eq(:http)
    end
  end
end
