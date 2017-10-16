RSpec.shared_examples 'a provider' do |api_content, resources, alternative_remote_states, get_request,
                                       update_request, create_request, delete_request, create_body,
                                      update_body, create_req_type, update_req_type, delete_req_type|
  # get the first element of resources as the resource we do most tests with
  resource = resources.values[0]

  describe '.list_resources' do
    context 'when the first two responses are unexpected' do
      it 'should retry 3 times' do
        stub_request(:get, get_request)
          .to_return(status: 400, body: '', headers: {}).times(2).then
          .to_return(status: 200, body: JSON.dump(api_content), headers: {})

        described_class.reset
        described_class.prefetch(resources)
        expect(resource.provider.ensure).to eql(:present)
      end
    end

    context 'when the first three responses are unexpected' do
      it 'should silently fail to prefetch' do
        stub_request(:get, get_request)
          .to_return(status: 400, body: '', headers: {})

        described_class.reset
        described_class.prefetch(resources)
        expect(resource.provider.ensure).to eql(:absent)
      end
    end

    context 'when a timeout is received' do
      it 'should not handle the timeout' do
        stub_request(:get, get_request)
          .to_timeout

        described_class.reset
        expect { described_class.prefetch resources }.to raise_error(Timeout::Error, 'execution expired')
      end
    end
  end

  describe '#exists?' do
    context 'when resource does not exists' do
      it 'should return false' do
        stub_request(:get, get_request)
          .to_return(status: 404, body: '', headers: {})

        described_class.reset
        described_class.prefetch(resources)
        expect(resource.provider.exists?).to eql(false)
      end
    end

    context 'when resource exists' do
      it 'it should return true' do
        stub_request(:get, get_request)
          .to_return(status: 200, body: JSON.dump(api_content), headers: {})

        described_class.reset
        described_class.prefetch(resources)
        expect(resource.provider.exists?).to eql(true)
      end
    end
  end

  describe '#create' do
    context 'when resource does not exist' do
      it 'should write to consul' do
        # assume the resource is defined as the first element of api_content.
        content = api_content[1..-1]

        stub_request(:get, get_request)
          .to_return(status: 200, body: JSON.dump(content), headers: {})

        # TODO: url and data
        stub_request(create_req_type, create_request)
          .with(body: create_body)
          .to_return(status: 200, body: '', headers: {})

        described_class.reset
        described_class.prefetch(resources)
        resource.provider.create
        resource.provider.flush
      end
    end

    context 'when resource does exist' do
      alternative_remote_states.each do |key, value|
        it "with '#{key}' attribute changed, it should update" do
          # make a copy of the array and duplicate the first entry for modification
          content = api_content.clone
          content[0] = content[0].dup
          content[0].merge!(value)

          stub_request(:get, get_request)
            .to_return(status: 200, body: JSON.dump(content), headers: {})

          # The update we get here is for the resource as specified in `resource`.
          # Which is the same for every iteration of this loop.
          stub_request(update_req_type, update_request)
            .with(body: update_body)
            .to_return(status: 200, body: '', headers: {})

          described_class.reset
          described_class.prefetch(resources)
          resource.provider.create
          resource.provider.flush

          expect(a_request(update_req_type, update_request))
            .to have_been_made.once
        end
      end

      it 'with same content, it should not write to consul' do
        stub_request(:get, get_request)
          .to_return(status: 200, body: JSON.dump(api_content), headers: {})

        described_class.reset
        described_class.prefetch(resources)
        resource.provider.create
        resource.provider.flush
      end
    end

    context 'when consul returns an error' do
      it 'should raise Puppet::Error on failed create' do
        content = []
        stub_request(:get, get_request)
          .to_return(status: 200, body: JSON.dump(content), headers: {})

        stub_request(create_req_type, create_request)
          .to_return(status: 400, body: '', headers: {})

        described_class.reset
        described_class.prefetch(resources)
        resource.provider.create
        expect { resource.provider.flush }.to raise_error(Puppet::Error)
      end
    end

    context 'when resource is to be deleted' do
      it 'and already exists, it should be deleted' do
        stub_request(:get, get_request)
          .to_return(status: 200, body: JSON.dump(api_content), headers: {})

        stub_request(delete_req_type, delete_request)
          .to_return(status: 200, body: '', headers: {})

        described_class.reset
        described_class.prefetch(resources)
        resource.provider.destroy
        resource.provider.flush
      end

      it 'and does not exists, nothing should happen' do
        content = []
        stub_request(:get, get_request)
          .to_return(status: 200, body: JSON.dump(content), headers: {})

        described_class.reset
        described_class.prefetch(resources)
        resource.provider.destroy
        resource.provider.flush
      end
    end
  end
end
