type Consul::TokenStruct = Struct[
  {
    description      => Optional[String[0]],
    accessor_id      => String[1],
    ensure           => Optional[Enum['present', 'absent']],
    secret_id        => Optional[String[1]],
    policies_by_name => Optional[Array[String]],
    policies_by_id   => Optional[Array[String]],
    acl_api_token    => Optional[String[1]],
    ca_file          => Optional[Stdlib::Absolutepath],
    ca_path          => Optional[Stdlib::Absolutepath],
    client_cert      => Optional[Stdlib::Absolutepath],
    client_key       => Optional[Stdlib::Absolutepath],
    protocol         => Optional[String[1]],
    port             => Optional[Integer[1, 65535]],
    hostname         => Optional[String[1]],
    api_tries        => Optional[Integer[1]],
  }
]
