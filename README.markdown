#puppet-consul
[![Build Status](https://travis-ci.org/solarkennedy/puppet-consul.png)](https://travis-ci.org/solarkennedy/puppet-consul)

##Installation

###What This Module Affects

* Installs the consul daemon (via url or package)
* Optionally installs a user to run it under
* Installs a configuration file (/etc/consul/config.json)
* Manages the consul service via upstart, sysv, or systemd
* Optionally installs the Web UI

##Usage

```puppet
class { 'consul':
  config_hash => {
      'datacenter' => 'east-aws',
      'data_dir'   => '/opt/consul',
      'log_level'  => 'INFO',
      'node_name'  => 'foobar',
      'server'     => true
  }
}
```

##Web UI

To install and run the Web UI, include `ui_dir` in the `config_hash`.  You may also 
want to change the `client_addr` to `0.0.0.0` from the default `127.0.0.1`, 
for example:
```puppet
class { 'consul':
  config_hash => {
      'datacenter'  => 'east-aws',
      'data_dir'    => '/opt/consul',
      'ui_dir'      => '/opt/consul/ui',
      'client_addr' => '0.0.0.0',
      'log_level'   => 'INFO',
      'node_name'   => 'foobar',
      'server'      => true
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

##Limitations

Depends on the JSON gem, or a modern ruby.

##Development
Open an [issue](https://github.com/solarkennedy/puppet-consul/issues) or 
[fork](https://github.com/solarkennedy/puppet-consul/fork) and open a 
[Pull Request](https://github.com/solarkennedy/puppet-consul/pulls)
