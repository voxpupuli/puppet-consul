#puppet-consul-fork
( Forked from solarkennedy/puppet-consul - https://github.com/solarkennedy/puppet-consul/ This file is also adapted from it.)

Original Doc and module by [Kyle Anderson](https://github.com/solarkennedy)

Modified far too extensively by [TJ Miller jr](https://github.com/MrDuctTape) to add Windows agent-side functionality.

Initial load date: 12/3/2015

##Installation
* Download the module and park it in your tenant/repository
* If you have Linux hosts, insure that [nanliu/staging](https://forge.puppetlabs.com/nanliu/staging) is included on your puppet master (See Dependencies, below)
* If you have Windows hosts and are using hiera, insure that you use Puppet filepath standards when building the .yaml files (examples below)
* For Windows use, you will need [NSSM](https://nssm.cc/) (Dependencies, below), and you will want to put the executable (nssm.exe) in *./files/nssm64
* Refer to Consul [Documentation](https://www.consul.io/docs/index.html) for configuration and parameters.
* If you use SSL keys (and you should), go get your own and them install them in *./files/agent_ssl/


##Compatibility
Any module release that is tagged with 0.4.* is compatible with the 0.4.x
versions of consul. Anything tagged with 0.5.* is compatible with consul
0.5.x, etc.


###What This Module Does
* Installs the consul (Server or agent) on Linux, and the agent on Windows (via url or package)
  * If installing from zip, you *must* ensure the unzip utility is available on the server (unzip, usually).
* Optionally installs a user to run it under
* Installs a configuration file (/etc/consul/config.json)
* Manages the consul service via upstart, sysv, systemd, or nssm.exe
* Optionally installs the Web UI (Linux only)
* Automatically updates/maintains $PATH in Windows (as Windows is picky about how that happens).

##Dependencies
* (Linux Only): Requires [nanliu/staging](https://forge.puppetlabs.com/nanliu/staging) to perform an installation on a Linux host. 
* (Windows Only): Requires [NSSM](https://nssm.cc/ ) (specifically nssm.exe) to perform an installation on a Windows host. 
* A working JSON gem on the puppet master server, or a modern/recent version of Ruby.

## Notes:
You will notice two distinct styles in here. That's because I didn't touch the original consul module I forked off of any more than necessary.

The certificates and keys that you find in here are 100% fake. They're only included as examples, so go use your own.

Certificates will be automatically selected and installed if you switch consul::do_ssl: on, but you will have to do one of two things to the module to make it work:
* use a file/dir structure similar to what you see in place now (in '*./files/agent_ssl'), and modify '*./manifests/keys_ssl.pp' to taste. It will work once you customize the names and add valid keys.
* modify 'manifests/keys_ssl.pp' to use [Vault](https://www.vaultproject.io/), [SecretServer](https://forge.puppetlabs.com/sshipway/ss), or whatever abstraction mechanism you prefer.
(Recommendation? Do the latter; leaving private certs loafing around will make your security guys very nervous.)

In our company, we use custom facts to make automation easier. And really - you should too! If you don't, well, you will need to update the params in keys_ssl.pp a bit to pull the right facts for your environment, and/or just correct the paths for your needs.


##Usage

###With Hiera:

####Linux (agent install):
```
classes:
 - consul
 - staging

# Generic and config entries:
consul::version: '0.5.2'
consul::config_dir: "/etc/consul"
consul::download_url_base: 'https://dl.bintray.com/mitchellh/consul/'
consul::do_ssl: true
consul::config_defaults:
  bind_addr : "%{::ipaddress}"
  datacenter: "%{::location}"
  data_dir: '/opt/consul'
  client_addr: "%{::ipaddress}"
  node_name: "%{::fqdn}"
consul::config_hash:
  retry_join:
    - '101.102.103.104'
    - 'some-peer.somedomain.com'
    - 'another-peer.somedomain.com'
  encrypt: 'YRblablablablahblahfake0=='
  ca_file: "/etc/consul/ssl/ca.cert"
  cert_file: "/etc/consul/ssl/consul.cert"
  key_file: "/etc/consul/ssl/consul.key"
  verify_server_hostname: true
  verify_outgoing: true
  verify_incoming: true
  domain: 'dev.consul.somedomain.com'
  rejoin_after_leave: true
  log_level: 'INFO'
  server: false
  advertise_addr: "%{::ipaddress}"

#consul::services:
#  "json-formatted config bits"
#consul::watches:
#  "json-formatted config bits"
#consul::checks:
#  "json-formatted config bits"

```

####Windows:

```

---
classes:
 - consul
#(nanliu/staging not needed here)

# Windows-specific...
consul::manage_user: false
consul::manage_group: false
consul::install_method: 'windows'
consul::params::package_target: 'C:/Consul'

# Generic and config entries:
consul::version: '0.5.2'
consul::config_dir: "C:/Consul/config"
consul::download_url_base: 'http://dl.bintray.com/mitchellh/consul'
consul::do_ssl: true
consul::config_defaults:
  bind_addr : "%{::ipaddress}"
  datacenter: "%{::location}"
  data_dir: 'C:/consul/data'
  client_addr: "%{::ipaddress}"
  node_name: "%{::fqdn}"
consul::config_hash:
  retry_join:
    - '101.102.103.104'
    - 'some-peer.somedomain.com'
    - 'another-peer.somedomain.com'
  encrypt: 'ZRblablablablahblahfake0=='
  ca_file: "/etc/consul/ssl/ca.cert"
  cert_file: "/etc/consul/ssl/consul.cert"
  key_file: "/etc/consul/ssl/consul.key"
  verify_server_hostname: true
  verify_outgoing: true
  verify_incoming: true
  domain: 'dev.consul.somedomain.com'
  rejoin_after_leave: true
  log_level: 'INFO'
  server: false
  advertise_addr: "%{::ipaddress}"

#consul::services:
#  "json-formatted config bits"
#consul::watches:
#  "json-formatted config bits"
#consul::checks:
#  "json-formatted config bits"
```
###Without Hiera:

To set up a single consul server, with several agents attached:
On the server:

```
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

```
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

```
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

##Web UI

To install and run the Web UI on the server, include `ui_dir` in the
`config_hash`. You may also want to change the `client_addr` to `0.0.0.0` from
the default `127.0.0.1`, for example:

```
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

```
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

```
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
it easy to declare in hiera.

## Watch Definitions

```
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

```
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

```
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

##Limitations

See Dependencies, above.

## Consul Template

[Consul Template](https://github.com/hashicorp/consul-template) is a piece of
software to dynamically write out config files using templates that are populated
with values from Consul. This module does not configure consul template. See
[gdhbashton/consul_template](https://github.com/gdhbashton/puppet-consul_template) for
a module that can do that.

##Development
Open an [issue](https://github.com/MrDuctTape/consul-fork/issues) or
[fork](https://github.com/MrDuctTape/consul-fork/fork) and open a
[Pull Request](https://github.com/MrDuctTape/consul-fork/pulls)
