require 'spec_helper'
require 'spec_helper_provider'
require 'json'
require 'addressable/template'

describe Puppet::Type.type(:consul_prepared_query).provider(:default) do
  api_content = [
    {
      'ID'              => '8f246b77-f3e1-ff88-5b48-8ec93abf3e05',
      'Name'            => 'sample',
      'Session'         => 'adf4238a-882b-9ddc-4a9d-5b6758e4159e',
      'Token'           => '',
      'Service'         => {
        'Service'       => 'redis',
        'Failover'      => {
          'NearestN'    => 3,
          'Datacenters' => %w[dc1 dc2]
        },
        'OnlyPassing'   => true,
        'Tags'          => %w[tag1 tag2]
      },
      'DNS'             => {
        'TTL'           => '10s'
      },
      'RaftIndex'       => {
        'CreateIndex'   => 23,
        'ModifyIndex'   => 42
      }
    },
    {
      'ID'              => '34234b77-f3e1-ff88-5b48-8ec93abf3e05',
      'Name'            => 'sample2',
      'Session'         => '3423438a-882b-9ddc-4a9d-5b6758e4159e',
      'Token'           => '',
      'Service'         => {
        'Service'       => 'redis',
        'Failover'      => {
          'NearestN'    => 3,
          'Datacenters' => %w[dc1 dc2]
        },
        'OnlyPassing'   => true,
        'Tags'          => %w[tag1 tag2]
      },
      'DNS'             => {
        'TTL'           => '10s'
      },
      'RaftIndex'       => {
        'CreateIndex'   => 23,
        'ModifyIndex'   => 42
      }
    },
    {
      'ID'              => 'asdasd-f3e1-ff88-5b48-8ec93abf3e05',
      'Name'            => 'sample3',
      'Session'         => 'asdas-882b-9ddc-4a9d-5b6758e4159e',
      'Token'           => '',
      'Service'         => {
        'Service'       => 'redis',
        'Failover'      => {
          'NearestN'    => 3,
          'Datacenters' => %w[dc1 dc2]
        },
        'OnlyPassing'   => true,
        'Tags'          => %w[tag1 tag2]
      },
      'DNS'             => {
        'TTL'           => '10s'
      },
      'RaftIndex'       => {
        'CreateIndex'   => 23,
        'ModifyIndex'   => 42
      }
    }
  ]

  resources = { 'sample' => Puppet::Type.type(:consul_prepared_query).new(
    :name                 => 'sample',
    :service_name         => 'redis',
    :service_failover_n   => 3,
    :service_failover_dcs => %w[dc1 dc2],
    :service_only_passing => true,
    :service_tags         => %w[tag1 tag2],
    :ttl                  => 10,
    :acl_api_token        => 'sampleToken',
    :retry_period         => 0
  ) }

  alternative_remote_states = {
    'token' => { 'Token' => 'different-token' },
    'service_name' => { 'Service' => { 'Service' => 'different' } },
    'ttl_0' => { 'DNS' => { 'TTL' => '' } },
    'ttl_5s' => { 'DNS' => { 'TTL' => '5s' } },
    'template' => { 'Template' => { 'Type' => 'bbb', 'Regexp' => 'aaa' } },
    'service_failover_dc' => { 'Service' => { 'Failover' => { 'Datacenters' => 'different' } } }
  }

  get_request = 'http://localhost:8500/v1/query'
  create_request = 'http://localhost:8500/v1/query'
  create_req_type = :post
  update_request = Addressable::Template.new('http://localhost:8500/v1/query/{id}')
  update_req_type = :put
  delete_request = Addressable::Template.new('http://localhost:8500/v1/query/{id}')
  delete_req_type = :delete
  create_body = '{"Name":"sample","Token":"","Service":{"Service":"redis","Near":"","Failover":{"NearestN":3,"Datacenters":["dc1","dc2"]},"OnlyPassing":true,"Tags":["tag1","tag2"]},"DNS":{"TTL":"10s"}}'
  update_body = '{"Name":"sample","Token":"","Service":{"Service":"redis","Near":"","Failover":{"NearestN":3,"Datacenters":["dc1","dc2"]},"OnlyPassing":true,"Tags":["tag1","tag2"]},"DNS":{"TTL":"10s"},"ID":"8f246b77-f3e1-ff88-5b48-8ec93abf3e05"}'

  include_examples('a provider', api_content, resources, alternative_remote_states,
                   get_request, update_request, create_request, delete_request,
                   create_body, update_body, create_req_type, update_req_type, delete_req_type)
end
