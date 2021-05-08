require 'spec_helper'

describe Puppet::Type.type(:consul_key_value) do
  it 'fails if no name is provided' do
    expect {
      Puppet::Type.type(:consul_key_value).new(type: 'client')
    }.to raise_error(Puppet::Error, %r{Title or name must be provided})
  end

  context 'with query parameters provided' do
    before :each do
      @key_value = Puppet::Type.type(:consul_key_value).new(
        name: 'sample/key',
        value: 'sampleValue',
        flags: 1,
      )
    end

    it 'defaults to localhost' do
      expect(@key_value[:hostname]).to eq('localhost')
    end

    it 'defaults to http' do
      expect(@key_value[:protocol]).to eq(:http)
    end
  end
end
