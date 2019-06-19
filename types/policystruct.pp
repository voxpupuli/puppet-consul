type Consul::PolicyStruct = Struct[{
  id            => Optional[String[1]],
  ensure        => Optional[Enum['present', 'absent']],
  description   => Optional[String[0]],
  rules         => Optional[Array[Struct[{
    resource    => String[1],
    segment     => Optional[String[0]],
    disposition => String[1],
  }]]],
  acl_api_token => Optional[String[1]],
  protocol      => Optional[String[1]],
  port          => Optional[Integer[1, 65535]],
  hostname      => Optional[String[1]],
  api_tries     => Optional[Integer[1]],
}]
