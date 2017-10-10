# consul_services.rb

Facter.add(:consul_services) do
  confine :kernel => 'Linux'

  confine do
    begin
      require 'facter/util/consul'
      true
    rescue LoadError
      false
    end
  end

  setcode do
	  Facter::Util::Consul.list_services
	end
end
