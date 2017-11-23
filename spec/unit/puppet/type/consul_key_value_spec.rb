describe Puppet::Type.type(:consul_key_value) do

  it 'should fail if no name is provided' do
    expect do
      Puppet::Type.type(:consul_key_value).new(:type => 'client')
    end.to raise_error(Puppet::Error, /Title or name must be provided/)
  end

  context 'with query parameters provided' do
    before :each do
      @key_value = Puppet::Type.type(:consul_key_value).new(
        :name  => 'sample/key',
        :value => 'sampleValue',
        :flags => 1,
      )
    end

    it 'should default to localhost' do
      expect(@key_value[:hostname]).to eq('localhost')
    end

    it 'should default to http' do
      expect(@key_value[:protocol]).to eq(:http)
    end
  end
end
