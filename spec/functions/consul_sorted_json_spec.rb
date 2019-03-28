require 'spec_helper'

def deprettyfy(string, leave_pretty)
  if leave_pretty
    return string
  else
    return string.gsub(/[[:space:]]/, '')
  end
end

RSpec.shared_examples 'handling_simple_types' do |pretty|
  it 'handles nil' do
    is_expected.to run.with_params({'key' => nil },pretty).and_return(deprettyfy("{\n    \"key\": null\n}\n",pretty))
  end
  it 'handles :undef' do
    is_expected.to run.with_params({'key' => :undef },pretty).and_return(deprettyfy("{\n    \"key\": null\n}\n",pretty))
  end
  it 'handles true' do
    is_expected.to run.with_params({'key' => true },pretty).and_return(deprettyfy("{\n    \"key\": true\n}\n",pretty))
  end
  it 'handles false' do
    is_expected.to run.with_params({'key' => false },pretty).and_return(deprettyfy("{\n    \"key\": false\n}\n",pretty))
  end
  it 'handles positive integer' do
    is_expected.to run.with_params({'key' => 1 },pretty).and_return(deprettyfy("{\n    \"key\": 1\n}\n",pretty))
  end
  it 'handles negative integer' do
    is_expected.to run.with_params({'key' => -1 },pretty).and_return(deprettyfy("{\n    \"key\": -1\n}\n",pretty))
  end
  it 'handles positive float' do
    is_expected.to run.with_params({'key' => 1.1 },pretty).and_return(deprettyfy("{\n    \"key\": 1.1\n}\n",pretty))
  end
  it 'handles negative float' do
    is_expected.to run.with_params({'key' => -1.1 },pretty).and_return(deprettyfy("{\n    \"key\": -1.1\n}\n",pretty))
  end
  it 'handles integer in a string' do
    is_expected.to run.with_params({'key' => '1' },pretty).and_return(deprettyfy("{\n    \"key\": 1\n}\n",pretty))
  end
  it 'handles zero in a string' do
    is_expected.to run.with_params({'key' => '0' },pretty).and_return(deprettyfy("{\n    \"key\": 0\n}\n",pretty))
  end
  it 'handles integers with a leading zero in a string' do
    is_expected.to run.with_params({'key' => '0640' },pretty).and_return(deprettyfy("{\n    \"key\": \"0640\"\n}\n",pretty))
  end
  it 'handles negative integer in a string' do
    is_expected.to run.with_params({'key' => '-1' },pretty).and_return(deprettyfy("{\n    \"key\": -1\n}\n",pretty))
  end
  it 'handles simple string' do
    is_expected.to run.with_params({'key' => 'aString' },pretty).and_return(deprettyfy("{\n    \"key\": \"aString\"\n}\n",pretty))
  end
  it 'quotes values of tags' do
    is_expected.to run.with_params({'tags' => 12 },pretty).and_return(deprettyfy("{\n    \"tags\": \"12\"\n}\n",pretty))
  end
  it 'quotes values of meta' do
    is_expected.to run.with_params({'meta' => {'sla' => 2 } },pretty).and_return(deprettyfy("{\n    \"meta\": {\n        \"sla\": \"2\"\n    }\n}\n",pretty))
  end
  it 'quotes values of node_meta' do
    is_expected.to run.with_params({'node_meta' => {'cpus' => 8 } },pretty).and_return(deprettyfy("{\n    \"node_meta\": {\n        \"cpus\": \"8\"\n    }\n}\n",pretty))
  end
end
describe 'consul::sorted_json', :type => :puppet_function do

  let(:test_hash){ { 'z' => 3, 'a' => '1', 'p' => '2', 's' => '-7' } }
  before do
    @json = subject.execute(test_hash, true)
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
    json = subject.execute(test_hash) # pretty=false by default
    expect(json.split("\n").size).to eql(1)
  end

  it "validate ugly json" do
    json = subject.execute(test_hash) # pretty=false by default
    expect(json).to match("{\"a\":1,\"p\":2,\"s\":-7,\"z\":3}")
  end

  it "handles nested :undef values" do
    nested_undef_hash = {
      'key' => 'value',
      'undef' => :undef,
      'nested_undef' => {
        'undef' => :undef
      }
    }
    json = subject.execute(nested_undef_hash)
    expect(json).to match("{\"key\":\"value\",\"nested_undef\":{\"undef\":null},\"undef\":null}")
  end

  context 'nesting' do

    let(:nested_test_hash){ { 'z' => [{'l' => 3, 'k' => '2', 'j'=> '1'}],
                              'a' => {'z' => '3', 'x' => '1', 'y' => '2'},
                              'p' => [ '9','8','7'] } }
    before do
      @json = subject.execute(nested_test_hash, true)
    end

    it "sorts nested hashes" do
      expect( @json.index('x') ).to be < @json.index('y')
      expect( @json.index('y') ).to be < @json.index('z')
    end

  end
  context 'test simple behavior' do
    context 'sorted' do
      include_examples 'handling_simple_types', false
    end
    context 'sorted pretty' do
      include_examples 'handling_simple_types', true
    end
  end
end
