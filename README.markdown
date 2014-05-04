#puppet-consul
[![Build Status](https://travis-ci.org/solarkennedy/puppet-consul.png)](https://travis-ci.org/solarkennedy/puppet-consul)

##Installation

###What This Module Affects

* Installs the consul daemon (via url or package)
* Optionally installs a user to run it under
* Installs a configuration file (/etc/consul/config.json)
* Manages the consul service via upstart

##Usage

```puppet
file { '/opt/consul/':
  ensure => 'directory',
  owner  => 'consul',
  group  => 'root',
} ->
class { 'consul':
  config_hash => {
      'datacenter' => 'east-aws',
      'data_dir'   => '/opt/consul',
      'log_level'  => 'INFO',
      'node_name'  => 'foobar',
      'server'     =>true
  }
}
```

##Limitations

This module requires upstart to manage the service. Patches welcome! (with tests)

Also it depends on the JSON gem, or a modern ruby.

##Development
Open an [issue](https://github.com/solarkennedy/puppet-consul/issues) or 
[fork](https://github.com/solarkennedy/puppet-consul/fork) and open a 
[Pull Request](https://github.com/solarkennedy/puppet-consul/pulls)
