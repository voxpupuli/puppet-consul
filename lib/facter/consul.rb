require 'facter'

# Example:
# $ consul -v
# Consul v0.5.0
# Consul Protocol: 2 (Understands back to: 1)
consul_v = Facter::Util::Resolution.exec("consul -v")

# If consul is not installed, the command above will
# fail and return nil
unless consul_v.nil?
  
  # Split the string into an array with 2 elements
  # and do some ruby shenanigans to extract consul
  # version and protocol
  consul_v = consul_v.split("\n")
  consul_version = consul_v.first.split.last.gsub('v', '')
  consul_protocol = consul_v.last.split[2]
  
  # Finally add the values to facter
  Facter.add(:consul_version) { setcode { consul_version } }
  Facter.add(:consul_protocol) { setcode { consul_protocol } }
end

