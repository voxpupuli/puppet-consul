require 'spec_helper'

%i[consul_acl consul_key_value consul_policy consul_prepared_query consul_token].each do |type_name|
  describe "#{type_name} TLS parameters" do
    let(:type) { Puppet::Type.type(type_name) }

    %i[ca_file ca_path client_cert client_key].each do |parameter|
      it "rejects relative #{parameter} paths" do
        expect { type.new(name: 'test', parameter => 'relative.pem') }.to raise_error(Puppet::Error, %r{must be an absolute path})
      end
    end

    it 'requires client_cert and client_key together' do
      expect { type.new(name: 'test', client_cert: '/client.pem') }.to raise_error(Puppet::Error, %r{must be supplied together})
      expect { type.new(name: 'test', client_key: '/client-key.pem') }.to raise_error(Puppet::Error, %r{must be supplied together})
    end

    it 'accepts private CA and mTLS paths as connection parameters' do
      resource = type.new(name: 'test', protocol: 'https', ca_file: '/ca.pem', ca_path: '/cas', client_cert: '/client.pem', client_key: '/client-key.pem')
      expect(resource[:ca_file]).to eq('/ca.pem')
      expect(resource.property(:client_cert)).to be_nil
    end

    it 'automatically requires managed TLS files and the service' do
      paths = ['/ca.pem', '/cas', '/client.pem', '/client-key.pem']
      resource = type.new(name: 'test', ca_file: paths[0], ca_path: paths[1], client_cert: paths[2], client_key: paths[3])
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource(resource)
      paths.each { |path| catalog.add_resource(Puppet::Type.type(:file).new(path: path)) }
      catalog.add_resource(Puppet::Type.type(:service).new(name: 'consul'))
      expect(resource.autorequire.map { |edge| edge.source.ref }).to contain_exactly(*paths.map { |path| "File[#{path}]" }, 'Service[consul]')
    end
  end
end
