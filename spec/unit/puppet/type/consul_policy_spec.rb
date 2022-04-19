require 'spec_helper'

describe Puppet::Type.type(:consul_policy) do
  it 'fails if no name is provided' do
    expect do
      Puppet::Type.type(:consul_policy).new(id: {}, rules: {})
    end.to raise_error(Puppet::Error, %r{Title or name must be provided})
  end

  it 'fails if ID ist not a string' do
    expect do
      Puppet::Type.type(:consul_policy).new(name: 'foo', id: {})
    end.to raise_error(Puppet::Error, %r{ID must be a string})
  end

  it 'fails if description ist not a string' do
    expect do
      Puppet::Type.type(:consul_policy).new(name: 'foo', description: {})
    end.to raise_error(Puppet::Error, %r{Description must be a string})
  end

  it 'fails if datacenters list is not an array' do
    expect do
      Puppet::Type.type(:consul_policy).new(name: 'foo', datacenters: [[]])
    end.to raise_error(Puppet::Error, %r{Datacenter name list must be an array of strings})
  end

  it 'fails if rules is not a hash' do
    expect do
      Puppet::Type.type(:consul_policy).new(
        name: 'testing',
        id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
        description: 'test description',
        rules: 'abc'
      )
    end.to raise_error(Puppet::Error, %r{Policy rule must be a hash})
  end

  it 'fails if rule resource is missing' do
    expect do
      Puppet::Type.type(:consul_policy).new(
        name: 'testing',
        id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
        description: 'test description',
        rules: [
          {
            'segment' => 'test_service',
            'disposition' => 'read'
          },
        ]
      )
    end.to raise_error(Puppet::Error, %r{Policy rule needs to specify a resource})
  end

  it 'fails if rule disposition is missing' do
    expect do
      Puppet::Type.type(:consul_policy).new(
        name: 'testing',
        id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
        description: 'test description',
        rules: [
          {
            'resource' => 'service_prefix',
            'segment' => 'test_service',
          },
        ]
      )
    end.to raise_error(Puppet::Error, %r{Policy rule needs to specify a disposition})
  end

  it 'fails if rule resource is not a string' do
    expect do
      Puppet::Type.type(:consul_policy).new(
        name: 'testing',
        id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
        description: 'test description',
        rules: [
          {
            'resource' => [],
            'segment' => 'test_service',
            'disposition' => 'read'
          },
        ]
      )
    end.to raise_error(Puppet::Error, %r{Policy rule resource must be a string})
  end

  it 'fails if rule disposition is not a string' do
    expect do
      Puppet::Type.type(:consul_policy).new(
        name: 'testing',
        id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
        description: 'test description',
        rules: [
          {
            'resource' => 'key_prefix',
            'segment' => 'test_service',
            'disposition' => []
          },
        ]
      )
    end.to raise_error(Puppet::Error, %r{Policy rule disposition must be a string})
  end

  context 'resource is acl, operator or keyring' do
    it 'passes if rule segment is missing' do
      expect do
        Puppet::Type.type(:consul_policy).new(
          name: 'testing',
          id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
          description: 'test description',
          rules: [
            {
              'resource' => 'acl',
              'disposition' => 'read'
            },
          ]
        )
        Puppet::Type.type(:consul_policy).new(
          name: 'testing',
          id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
          description: 'test description',
          rules: [
            {
              'resource' => 'operator',
              'disposition' => 'read'
            },
          ]
        )
        Puppet::Type.type(:consul_policy).new(
          name: 'testing',
          id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
          description: 'test description',
          rules: [
            {
              'resource' => 'keyring',
              'disposition' => 'read'
            },
          ]
        )
      end.not_to raise_error
    end

    it 'passes if rule segment is not a string' do
      expect do
        Puppet::Type.type(:consul_policy).new(
          name: 'testing',
          id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
          description: 'test description',
          rules: [
            {
              'resource' => 'operator',
              'segment' => [],
              'disposition' => 'read'
            },
          ]
        )
      end.not_to raise_error
    end
  end

  context 'resource is neither acl nor operator nor keyring' do
    it 'fails if rule segment is missing' do
      expect do
        Puppet::Type.type(:consul_policy).new(
          name: 'testing',
          id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
          description: 'test description',
          rules: [
            {
              'resource' => 'service_prefix',
              'disposition' => 'read'
            },
          ]
        )
      end.to raise_error(Puppet::Error, %r{Policy rule needs to specify a segment})
    end

    it 'fails if rule segment is not a string' do
      expect do
        Puppet::Type.type(:consul_policy).new(
          name: 'testing',
          id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
          description: 'test description',
          rules: [
            {
              'resource' => 'key_prefix',
              'segment' => [],
              'disposition' => 'read'
            },
          ]
        )
      end.to raise_error(Puppet::Error, %r{Policy rule segment must be a string})
    end
  end

  context 'with name defined' do
    rules = [
      {
        'resource' => 'service_prefix',
        'segment' => 'test_service',
        'disposition' => 'read'
      },
      {
        'resource' => 'key_prefix',
        'segment' => 'key',
        'disposition' => 'write'
      },
    ]
    datacenters = ['testdc']

    before do
      @policy = Puppet::Type.type(:consul_policy).new(
        name: 'testing',
        id: '39c75e12-7f43-0a40-dfba-9aa3fcda08d4',
        description: 'test description',
        datacenters: datacenters,
        rules: rules
      )
    end

    it 'accepts an id' do
      expect(@policy[:id]).to eq('39c75e12-7f43-0a40-dfba-9aa3fcda08d4')
    end

    it 'accepts a description' do
      expect(@policy[:description]).to eq('test description')
    end

    it 'accepts datacenters' do
      expect(@policy[:datacenters]).to eq(datacenters)
    end

    it 'accepts rules' do
      expect(@policy[:rules]).to eq(rules)
    end

    it 'defaults to localhost' do
      expect(@policy[:hostname]).to eq('localhost')
    end

    it 'defaults to http' do
      expect(@policy[:protocol]).to eq(:http)
    end

    it 'defaults to port 8500' do
      expect(@policy[:port]).to eq(8500)
    end
  end
end
