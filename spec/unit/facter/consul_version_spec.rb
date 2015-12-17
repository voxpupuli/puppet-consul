require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
    allow(Facter.fact(:kernel)).to receive(:value).and_return("Linux")
  }

  describe "consul_version" do
    it do
      consul_version_output = <<-EOS
Consul v0.6.0
Consul Protocol: 3 (Understands back to: 1)
      EOS
      allow(Facter::Util::Resolution).to receive(:exec).with('consul --version').
        and_return(consul_version_output)
      expect(Facter.fact(:consul_version).value).to match(/\d+\.\d+\.\d+/)
    end
  end

end
