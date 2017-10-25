$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))
require 'puppet_x/consul/hiera'
require 'spec_helper'

# This manner of implementing hiera backend is only availabe from puppet 4.
describe 'FakeFunction', :if => Puppet.version.to_f >= 4.0 do
  let(:function) do
    # Load the monkey patch that allows us to test this.
    require 'spec_helper_hiera'
    Puppet::Functions.start_monkey_patch
    require 'puppet/functions/hiera_consul'

    # disable the monkey patch to avoid problems with the other tests.
    Puppet::Functions.stop_monkey_patch
    FakeFunction.new
  end

  describe '#lookup_key' do
    context 'Should run' do
      it 'should call shared library' do
        context = instance_double('Puppet::LookupContext')
        options = {}

        expect(PuppetX::Consul::Hiera).to receive(:lookup_key).with('bar', options, context).and_return('hello bar')

        expect(function.lookup_key('bar', options, context)).to eq('hello bar')
      end
    end
  end
end
