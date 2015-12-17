require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe "consul_version" do

    context 'Returns consul version on Linux'
    it do
      consul_version_output = <<-EOS
Consul v0.6.0
Consul Protocol: 3 (Understands back to: 1)
      EOS
      allow(Facter.fact(:kernel)).to receive(:value).and_return("Linux")
      allow(Facter::Util::Resolution).to receive(:exec).with('consul --version').
        and_return(consul_version_output)
      expect(Facter.fact(:consul_version).value).to match(/\d+\.\d+\.\d+/)
    end

    context 'Returns consul version on Windows'
    it do
      consul_version_output = <<-EOS
Consul v0.6.0
Consul Protocol: 3 (Understands back to: 1)
      EOS
      allow(Facter.fact(:kernel)).to receive(:value).and_return("windows")
      allow(Facter::Util::Resolution).to receive(:exec).with('"C:\\Program Files\\Consul\\consul.exe" --version').
        and_return(consul_version_output)
      expect(Facter.fact(:consul_version).value).to match(/\d+\.\d+\.\d+/)
    end


  end

end
