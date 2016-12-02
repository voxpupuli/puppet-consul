# puppet-consul
[![Build Status](https://travis-ci.org/solarkennedy/puppet-consul.png)](https://travis-ci.org/solarkennedy/puppet-consul)
[![Puppet Forge](https://img.shields.io/puppetforge/e/KyleAnderson/consul.svg)](https://forge.puppetlabs.com/KyleAnderson/consul)
[![Puppet Forge](https://img.shields.io/puppetforge/v/KyleAnderson/consul.svg)](https://forge.puppetlabs.com/KyleAnderson/consul)
[![Puppet Forge](https://img.shields.io/puppetforge/f/KyleAnderson/consul.svg)](https://forge.puppetlabs.com/KyleAnderson/consul)

## Compatibility

| Consul Version   | Recommended Puppet Module Version   |
| ---------------- | ----------------------------------- |
| >= 0.6.0         | latest                              |
| 0.5.x            | 1.0.3                               |
| 0.4.x            | 0.4.6                               |
| 0.3.x            | 0.3.0                               |

### What This Module Affects

* Installs the consul daemon (via url or package)
  * If installing from zip, you *must* ensure the unzip utility is available.
* Optionally installs a user to run it under
* Installs a configuration file (/etc/consul/config.json)
* Manages the consul service via upstart, sysv, or systemd
* Optionally installs the Web UI

## Usage

To set up a single consul server, with several agents attached:
On the server:
```puppet
class { '::consul':
  config_hash => {
    'bootstrap_expect' => 1,
    'data_dir'         => '/opt/consul',
    'datacenter'       => 'east-aws',
    'log_level'        => 'INFO',
    'node_name'        => 'server',
    'server'           => true,
  }
}
```
On the agent(s):
```puppet
class { '::consul':
  config_hash => {
    'data_dir'   => '/opt/consul',
    'datacenter' => 'east-aws',
    'log_level'  => 'INFO',
    'node_name'  => 'agent',
    'retry_join' => ['172.16.0.1'],
  }
}
```
Disable install and service components:
```puppet
class { '::consul':
  install_method => 'none',
  init_style     => false,
  manage_service => false,
  config_hash => {
    'data_dir'   => '/opt/consul',
    'datacenter' => 'east-aws',
    'log_level'  => 'INFO',
    'node_name'  => 'agent',
    'retry_join' => ['172.16.0.1'],
  }
}
```

## Web UI

To install and run the Web UI on the server, include `ui_dir` in the
`config_hash`. You may also want to change the `client_addr` to `0.0.0.0` from
the default `127.0.0.1`, for example:
```puppet
class { '::consul':
  config_hash => {
    'bootstrap_expect' => 1,
    'client_addr'      => '0.0.0.0',
    'data_dir'         => '/opt/consul',
    'datacenter'       => 'east-aws',
    'log_level'        => 'INFO',
    'node_name'        => 'server',
    'server'           => true,
    'ui_dir'           => '/opt/consul/ui',
  }
}
```
For more security options, consider leaving the `client_addr` set to `127.0.0.1`
and use with a reverse proxy:
```puppet
$aliases = ['consul', 'consul.example.com']

# Reverse proxy for Web interface
include 'nginx'

$server_names = [$::fqdn, $aliases]

nginx::resource::vhost { $::fqdn:
  proxy       => 'http://localhost:8500',
  server_name => $server_names,
}
```

## Service Definition

To declare the availability of a service, you can use the `service` define. This
will register the service through the local consul client agent and optionally
configure a health check to monitor its availability.

```puppet
::consul::service { 'redis':
  checks  => [
    {
      script   => '/usr/local/bin/check_redis.py',
      interval => '10s'
    }
  ],
  port    => 6379,
  tags    => ['master']
}
```

See the service.pp docstrings for all available inputs.

You can also use `consul::services` which accepts a hash of services, and makes
it easy to declare in hiera. For example:

```puppet
consul::services:
  service1:
    address: "%{::ipaddress}"
    checks:
      - http: http://localhost:42/status
        interval: 5s
    port: 42
    tags:
      - "foo:%{::bar}"
  service2:
    address: "%{::ipaddress}"
    checks:
      - http: http://localhost:43/status
        interval: 5s
    port: 43
    tags:
      - "foo:%{::baz}"
```

## Watch Definitions

```puppet
::consul::watch { 'my_watch':
  handler     => 'handler_path',
  passingonly => true,
  service     => 'serviceName',
  service_tag => 'serviceTagName',
  type        => 'service',
}
```

See the watch.pp docstrings for all available inputs.

You can also use `consul::watches` which accepts a hash of watches, and makes
it easy to declare in hiera.

## Check Definitions

```puppet
::consul::check { 'true_check':
  interval => '30s',
  script   => '/bin/true',
}
```

See the check.pp docstrings for all available inputs.

You can also use `consul::checks` which accepts a hash of checks, and makes
it easy to declare in hiera.

## Removing Service, Check and Watch definitions

Do `ensure => absent` while removing existing service, check and watch
definitions. This ensures consul will be reloaded via `SIGHUP`. If you have
`purge_config_dir` set to `true` and simply remove the definition it will cause
consul to restart.

## ACL Definitions

```puppet
consul_acl { 'ctoken':
  ensure => 'present',
  rules  => {'key' => {'test' => {'policy' => 'read'}}},
  type   => 'client',
}
```

Do not use duplicate names, and remember that the ACL ID (a read-only property for this type)
is used as the token for requests, not the name

Optionally, you may supply an `acl_api_token`.  This will allow you to create
ACLs if the anonymous token doesn't permit ACL changes (which is likely).
The api token may be the master token, another management token, or any
client token with sufficient privileges.

## Prepared Queries and Prepared Query Templates

```puppet
consul_prepared_query { 'consul':
  ensure               => 'present',
  service_name         => 'consul',
  service_failover_n   => 1,
  service_failover_dcs => [ 'dc1', 'dc2' ],
  service_only_passing => true,
  service_tags         => [ 'tag1', 'tag2' ],
  ttl                  => 10,
}
```

or a prepared query template:

```puppet
consul_prepared_query { 'consul':
  ensure               => 'present',
  service_name         => 'consul',
  service_name         => 'consul-${match(1)}' # lint:ignore:single_quote_string_with_variables
  service_failover_n   => 1,
  service_failover_dcs => [ 'dc1', 'dc2' ],
  service_only_passing => true,
  service_tags         => [ '${match(2)}' ], # lint:ignore:single_quote_string_with_variables
  template             => true,
  template_regexp      => '^consul-(.*)-(.*)$',
  template_type        => 'name_prefix_match',
}
```

## Key/Value Objects

```puppet
consul_key_value { 'key/path':
  ensure => 'present',
  value  => 'myvaluestring',
  flags  => 12345,
}
```

This provider allows you to manage key/value pairs.

## Limitations

Depends on the JSON gem, or a modern ruby. (Ruby 1.8.7 is not officially supported)

## Consul Template

[Consul Template](https://github.com/hashicorp/consul-template) is a piece of
software to dynamically write out config files using templates that are populated
with values from Consul. This module does not configure consul template. See
[gdhbashton/consul_template](https://github.com/gdhbashton/puppet-consul_template) for
a module that can do that.

## Development
Open an [issue](https://github.com/solarkennedy/puppet-consul/issues) or
[fork](https://github.com/solarkennedy/puppet-consul/fork) and open a
[Pull Request](https://github.com/solarkennedy/puppet-consul/pulls)
