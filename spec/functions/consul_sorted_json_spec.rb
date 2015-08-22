require 'spec_helper'

describe 'consul_sorted_json', :type => :puppet_function do

  let(:test_hash){ { 'z' => 3, 'a' => '1', 'p' => '2', 's' => '-7' } }
  before do
    @json = subject.call([test_hash, true])
  end
  it "sorts keys" do
    expect( @json.index('a') ).to be < @json.index('p')
    expect( @json.index('p') ).to be < @json.index('s')
    expect( @json.index('s') ).to be < @json.index('z')
  end

  it "prints pretty json" do
    expect(@json.split("\n").size).to eql(test_hash.size + 2) # +2 for { and }
  end

  it "prints ugly json" do
    json = subject.call([test_hash]) # pretty=false by default
    expect(json.split("\n").size).to eql(1)
  end

  it "validate ugly json" do
    json = subject.call([test_hash]) # pretty=false by default
    expect(json).to match("{\"a\":1,\"p\":2,\"s\":-7,\"z\":3}")
  end

  context 'nesting' do

    let(:nested_test_hash){ { 'z' => [{'l' => 3, 'k' => '2', 'j'=> '1'}],
                              'a' => {'z' => '3', 'x' => '1', 'y' => '2'},
                              'p' => [ '9','8','7'] } }
    before do
      @json = subject.call([nested_test_hash, true])
    end

    it "sorts nested hashes" do
      expect( @json.index('x') ).to be < @json.index('y')
      expect( @json.index('y') ).to be < @json.index('z')
    end

  end
end
