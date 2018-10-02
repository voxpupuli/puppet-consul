require 'spec_helper'

describe Puppet::Type.type(:consul_acl) do

  samplerules = {
    'key' => {
      'test' => {
        'policy' => 'read'
      }
    }
  }

  it 'should fail if type is not client or management' do
    expect do
      Puppet::Type.type(:consul_acl).new(:name => 'foo', :type => 'blah')
    end.to raise_error(Puppet::Error, /Invalid value/)
  end

  it 'should fail if rules is not a hash' do
    expect do
      Puppet::Type.type(:consul_acl).new(:name => 'foo', :rules => 'blah')
    end.to raise_error(Puppet::Error, /ACL rules must be provided as a hash/)
  end

  it 'should fail if no name is provided' do
    expect do
      Puppet::Type.type(:consul_acl).new(:type => 'client')
    end.to raise_error(Puppet::Error, /Title or name must be provided/)
  end

  context 'with type and rules provided' do
    before :each do
      @acl = Puppet::Type.type(:consul_acl).new(
        :name => 'testing',
        :type => 'management',
        :rules => samplerules
      )
    end

    it 'should accept a type' do
      expect(@acl[:type]).to eq(:management)
    end

    it 'should default to localhost' do
      expect(@acl[:hostname]).to eq('localhost')
    end

    it 'should accept a hash of rules' do
      expect(@acl[:rules]).to eq(samplerules)
    end

    it 'should default to http' do
      expect(@acl[:protocol]).to eq(:http)
    end
  end
end
