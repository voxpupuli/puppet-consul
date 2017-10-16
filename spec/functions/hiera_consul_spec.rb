require 'spec_helper_hiera'
require 'puppet/functions/hiera_consul'

describe FakeFunction do
    let(:function) { described_class.new }
    
    describe "#lookup_key" do
      context "Should run" do
        it "should call shared library" do
          context = instance_double("Puppet::LookupContext")
          options = {}
        
          expect(PuppetX::Consul::Hiera).to receive(:lookup_key).with('bar', options, context).and_return('hello bar')
        
          expect(function.lookup_key('bar', options, context)).to eq('hello bar')
        end
      end
    end
  end