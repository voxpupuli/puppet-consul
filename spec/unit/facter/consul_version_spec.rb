require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
    allow(Facter.fact(:kernel)).to receive(:value).and_return("Linux")
  }

  describe "consul_version" do
    it do
      expect(Facter.fact(:consul_version).value).to match(/(?:(\d+)\.)?(?:(\d+)\.)?(\d+)/)
    end
  end

end
