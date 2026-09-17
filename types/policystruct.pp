type Consul::PolicyStruct = Struct[
  {
    id            => Optional[String[1]],
    ensure        => Optional[Enum['present', 'absent']],
    description   => Optional[String[0]],
    datacenters   => Optional[Array[String[1]]],
    rules         => Optional[Array[Struct[{
      resource    => String[1],
      segment     => Optional[String[0]],
      disposition => String[1],
    }]]],
    acl_api_token => Optional[String[1]],
    ca_file          => Optional[Stdlib::Absolutepath],
    ca_path          => Optional[Stdlib::Absolutepath],
    client_cert      => Optional[Stdlib::Absolutepath],
    client_key       => Optional[Stdlib::Absolutepath],
    protocol      => Optional[String[1]],
    port          => Optional[Integer[1, 65535]],
    hostname      => Optional[String[1]],
    api_tries     => Optional[Integer[1]],
  }
]
