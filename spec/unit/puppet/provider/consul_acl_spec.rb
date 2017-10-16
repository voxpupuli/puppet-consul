require 'spec_helper'
require 'spec_helper_provider'
require 'json'
require 'addressable/template'

describe Puppet::Type.type(:consul_acl).provider(:default) do
  api_content = [
    {
      'ID'          => '5d9c8431-fe3d-a5c5-4b01-d9aab0a7e5fd',
      'Name'        => 'sample',
      'Type'        => 'client',
      'Rules'       => '{"key":{"test":{"policy":"read"}}}',
      'CreateIndex' => 25,
      'ModifyIndex' => 25
    },
    {
      'ID'          => 'anonymous',
      'Name'        => 'Anonymous Token',
      'Type'        => 'client',
      'Rules'       => '',
      'CreateIndex' => 4,
      'ModifyIndex' => 4
    },
    {
      'ID'          => 'eaaf9434-62f6-74c3-ce2d-fc7d1b96e3dc',
      'Name'        => 'Bootstrap Token',
      'Type'        => 'management',
      'Rules'       => '',
      'CreateIndex' => 10,
      'ModifyIndex' => 10
    }
  ]

  resources = { 'sample' => Puppet::Type.type(:consul_acl).new(:name => 'sample',
                                                               :type          => 'client',
                                                               :acl_api_token => 'sampleToken',
                                                               :rules         => { 'key' => { 'test' => { 'policy' => 'read' } } }
                                                               )}
                                                              

  alternative_remote_states = {
    'type'  => { 'Type'  => 'management' },
    'rules' => { 'Rules' => '{"key":{"differentkey":{"policy":"read"}}}' },
    'all'   => { 'Type'  => 'management', 'Rules' => '{"key":{"differentkey":{"policy":"read"}}}' }
  }

  get_request     = 'http://localhost:8500/v1/acl/list'
  create_request  = 'http://localhost:8500/v1/acl/create'
  create_req_type = :put
  update_request  = 'http://localhost:8500/v1/acl/update'
  update_req_type = :put
  delete_request  = Addressable::Template.new('http://localhost:8500/v1/acl/destroy/{id}')
  delete_req_type = :put
  create_body     = "{\"Name\":\"sample\",\"Type\":\"client\",\"Rules\":\"{\\\"key\\\":{\\\"test\\\":{\\\"policy\\\":\\\"read\\\"}}}\"}"
  update_body     = '{"ID":"5d9c8431-fe3d-a5c5-4b01-d9aab0a7e5fd","Name":"sample","Type":"client","Rules":"{\\"key\\":{\\"test\\":{\\"policy\\":\\"read\\"}}}"}'

  include_examples('a provider', api_content, resources, alternative_remote_states,
                   get_request, update_request, create_request, delete_request,
                   create_body, update_body, create_req_type, update_req_type, delete_req_type)
end
