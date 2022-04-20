require 'spec_helper'

describe Puppet::Type.type(:consul_token) do
  it 'fails if no name is provided' do
    expect do
      Puppet::Type.type(:consul_token).new(type: 'client')
    end.to raise_error(Puppet::Error, %r{Title or name must be provided})
  end

  it 'fails if accessor_id ist not a string' do
    expect do
      Puppet::Type.type(:consul_token).new(name: 'foo', accessor_id: {})
    end.to raise_error(Puppet::Error, %r{ID must be a string})
  end

  it 'fails if secret_id ist not a string' do
    expect do
      Puppet::Type.type(:consul_token).new(name: 'foo', secret_id: {})
    end.to raise_error(Puppet::Error, %r{ID must be a string})
  end

  it 'fails if policy name list is not an array' do
    expect do
      Puppet::Type.type(:consul_token).new(name: 'foo', policies_by_name: [[]])
    end.to raise_error(Puppet::Error, %r{Policy name list must be an array of strings})
  end

  it 'fails if policy ID list is not an array' do
    expect do
      Puppet::Type.type(:consul_token).new(name: 'foo', policies_by_id: [[]])
    end.to raise_error(Puppet::Error, %r{Policy ID list must be an array of strings})
  end

  context 'with name defined' do
    policies_by_name = ['test_1' 'test_2']
    policies_by_id = ['abc-123' 'xyz-456']

    before do
      @token = Puppet::Type.type(:consul_token).new(
        name: 'testing',
        accessor_id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
        policies_by_name: policies_by_name,
        policies_by_id: policies_by_id
      )
    end

    it 'accepts a accessor id' do
      expect(@token[:accessor_id]).to eq('39c75e12-7f43-0a40-dfba-9aa3fcda08d4')
    end

    it 'accepts policy names' do
      expect(@token[:policies_by_name]).to eq(policies_by_name)
    end

    it 'accepts policy IDs' do
      expect(@token[:policies_by_id]).to eq(policies_by_id)
    end

    it 'defaults to localhost' do
      expect(@token[:hostname]).to eq('localhost')
    end

    it 'defaults to http' do
      expect(@token[:protocol]).to eq(:http)
    end

    it 'defaults to port 8500' do
      expect(@token[:port]).to eq(8500)
    end
  end
end
