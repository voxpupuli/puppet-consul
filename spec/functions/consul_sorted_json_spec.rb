require 'spec_helper'

describe 'consul_sorted_json', :type => :puppet_function do

  let(:test_hash){ { 'z' => 3, 'a' => '1', 'p' => '2' } }
  before do
    @json = subject.call([nested_test_hash])
  end
  it "sorts keys" do
    expect( @json.index('a') ).to be < json.index('p')
    expect( @json.index('p') ).to be < json.index('z')
  end

  it "requires one argument" do
    expect{subject.call([])}.to raise_error(Puppet::ParseError)
  end

  it "prints pretty json" do
    expect(json.split("\n").size).to eql(test_hash.size + 2) # +2 for { and }
  end

  it "converts numbers to integers" do
    expect(JSON.parse(json)).to have_attributes(:values => [1,2,3])
  end

  context 'nesting' do

    let(:nested_test_hash){ { 'z' => [{'l' => 3, 'k' => '2', 'j'=> '1'}],
                              'a' => {'z' => '3', 'x' => '1', 'y' => '2'},
                              'p' => [ '9','8','7'] } }
    before do
      @json = subject.call([nested_test_hash])
    end
    it "sorts and converts numbers to integers of a hash in an array" do
      expect(JSON.parse(@json).fetch('z')[0]).to have_attributes(:values => [1,2,3])
    end

    it "does not sort an array" do
      expect(JSON.parse(@json).fetch('p')).to eql([9,8,7])
    end

    it "sorts nested hashes" do
      expect(JSON.parse(@json).fetch('a')).to have_attributes(:keys => ['x','y','z'])
    end
  end
end
