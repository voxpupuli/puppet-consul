require 'puppet_x'

module PuppetX::Consul
  module TLSParameters
    class Path < Puppet::Parameter
      validate do |value|
        raise ArgumentError, "#{name} must be an absolute path" unless value.is_a?(String) && Puppet::Util.absolute_path?(value)
      end
    end

    def self.apply(type)
      type.validate do
        raise Puppet::Error, 'Consul client_cert and client_key must be supplied together' if self[:client_cert].nil? != self[:client_key].nil?
      end

      type.autorequire(:file) do
        %i[ca_file ca_path client_cert client_key].filter_map { |parameter| self[parameter] }
      end
    end
  end
end
